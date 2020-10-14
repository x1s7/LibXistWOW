
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
    data = data and Xist_Util.DeepCopy(data) or {index = index}
    return data
end


function Xist_Queue:ResetItem(index, data)
    if data then
        data = Xist_Util.DeepCopy(data)
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


function Xist_Queue:Iterate()
    local q = self
    local serial = self.serial
    local i = self.firstIndex
    local n = 0
    local done = false
    local item
    return function()
        --DEBUG("Iterate", {n=n, i=i, done=done, len=#q.items})

        n = n + 1
        if n > #q.items then
            done = true
        end

        if done then return nil end

        if q.serial ~= serial then
            error('Queue order changed while iterating')
        end

        item = q.items[i]

        if i < #q.items then
            i = i + 1
        elseif i == q.items then
            i = 1
        end

        if i == q.firstIndex then
            done = true
        end

        return item
    end
end


function Xist_Queue:SetMaxLength(maxLength)
    -- if we're in a wrapped situation, we need to reorder
    if self.firstIndex > 1 then
        local reorder = {}

        for i = self.firstIndex, #self.items do
            table.insert(reorder, self.items[i])
        end

        for i = 1, self.firstIndex - 1 do
            table.insert(reorder, self.items[i])
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
        item = self:ResetItem(index, data)
    end

    if index < self.firstIndex then
        self.firstIndex = self.firstIndex + 1
        if self.firstIndex > self.maxLength then
            self.firstIndex = 1
        end
    end

    self.nextIndex = index + 1
    if self.nextIndex > self.maxLength and self.maxLength > 0 then
        self.nextIndex = 1
    end

    return item
end
