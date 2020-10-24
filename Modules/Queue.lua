
local ModuleName = "Xist_Queue"
local ModuleVersion = 1

-- If some other addon installed Xist_Queue, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Queue
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_Queue
Xist_Queue = M

protected.DebugEnabled = true

local DEBUG = protected.DEBUG


function Xist_Queue:New(maxLength)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.items = {}
    obj.maxLength = maxLength or 0
    obj.serial = 1

    obj.firstIndex = 1
    obj.nextIndex = 1

    return obj
end


function Xist_Queue:CreateItem(index, data)
    if type(data) == 'function' then
        data = data(nil, index)
    elseif data then
        data = Xist_Util.Copy(data)
    else
        data = {index = index}
    end
    return data
end


function Xist_Queue:ResetItem(index, data, item)
    if type(data) == 'function' then
        data = data(item, index)
    elseif data then
        data = Xist_Util.Copy(data)
    else
        data = {
            index = index,
            reset = true,
        }
    end
    return data
end


function Xist_Queue:GetLength()
    return #self.items
end


function Xist_Queue:GetMaxLength()
    return self.maxLength
end


function Xist_Queue:GetPreviousItem(index)
    if #self.items <= 1 or index == self.firstIndex then
        return nil
    end
    local i
    if index == 1 then
        i = #self.items
    else
        i = index - 1
    end
    return self.items[i], i
end


function Xist_Queue:GetNextItem(index)
    if #self.items <= 1 then
        return nil
    end
    local i
    if index == #self.items then
        i = 1
    else
        i = index + 1
    end
    if i == self.firstIndex then
        return nil
    end
    return self.items[i], i
end


function Xist_Queue:Iterate()
    local q = self
    local serial = self.serial
    local i = self.firstIndex
    local nextItem = q.items[i] -- possibly nil
    local item
    return function()

        if q.serial ~= serial then
            error('Queue order changed while iterating')
        end

        item = nextItem

        if item then
            nextItem, i = q:GetNextItem(i)
        end

        return item
    end
end


function Xist_Queue:SetMaxLength(maxLength)
    -- if we're in a wrapped situation, we need to reorder
    if self.firstIndex > 1 then
        local reorder = {}

        for i = self.firstIndex, #self.items do
            reorder[1+#reorder] = self.items[i]
        end

        for i = 1, self.firstIndex - 1 do
            reorder[1+#reorder] = self.items[i]
        end

        -- now apply the reorder so we can extend the end of the item list
        self.items = reorder
        self.firstIndex = 1
        self.nextIndex = 1

        -- update the serial number to stop any executing iterators
        self.serial = self.serial + 1
    end

    self.maxLength = maxLength
end


function Xist_Queue:IndexPlusOne(index)
    index = index + 1
    if index > self.maxLength and self.maxLength > 0 then
        index = 1
    end
    return index
end


function Xist_Queue:Allocate(data)

    local index = self.nextIndex
    local item

    -- if we're limiting the queue size and the queue is full then reuse
    -- the oldest item in the queue.
    if self.maxLength > 0 then
        if #self.items >= self.maxLength then
            item = self.items[index]
        end
    end

    -- if we need to create a new item, do so now
    if not item then
        -- there is no item, we need to create one and add it to the queue
        item = self:CreateItem(index, data)
        self.items[index] = item
    else
        item = self:ResetItem(index, data, item)

        -- queue is full, we need to advance firstIndex with each allocation
        self.firstIndex = self:IndexPlusOne(self.firstIndex)
    end

    -- we allocated a slot, advance nextIndex
    self.nextIndex = self:IndexPlusOne(self.nextIndex)

    return item
end
