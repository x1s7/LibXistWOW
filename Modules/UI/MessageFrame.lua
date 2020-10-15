
local ModuleName = "Xist_UI_MessageFrame"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_MessageFrame, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_MessageFrame
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_MessageFrame
Xist_UI_MessageFrame = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local MESSAGE = protected.MESSAGE


function Xist_UI_MessageFrame:InitializeMessageFrameWidget()
    local classConf = self:GetWidgetClassConfig()
    local font = self:GetWidgetFontObject()

    self.messageQueue = Xist_Queue:New(classConf.maxLines or 10)
    self.linePadding = classConf.linePadding or 2
    self.lineSpacing = classConf.lineSpacing or 2
    self.totalHeight = 0
    self.fontHeight = font:GetFontHeight()
end


function Xist_UI_MessageFrame:GetLineHeight()
    return self.lineSpacing + self.fontHeight
end


function Xist_UI_MessageFrame:SetParent(parent)
    self:_SetParent(parent)
    self:SetWidth(parent:GetWidth())
    self:SetHeight(parent:GetHeight())
    self:ClearAllPoints()
    self:SetPoint('BOTTOM')
end


function Xist_UI_MessageFrame:GetTotalHeight()
    return self.totalHeight
end


function Xist_UI_MessageFrame:GetMaxMessages()
    return self.messageQueue:GetMaxLength()
end


function Xist_UI_MessageFrame:SetMaxMessages(limit)
    self.messageQueue:SetMaxLength(limit)
end


function Xist_UI_MessageFrame:AllocateMessageData()
    -- create new font string if needed, else reuse existing one
    local frame = self
    return self.messageQueue:Allocate(function(item, index)
        if not item then
            -- this spot in the queue is currently empty.
            -- Allocate a new FontString widget.

            local classConf = frame:GetWidgetClassConfig()
            local fontClass = classConf.fontClass or frame.widgetClass or 'default'
            item = {
                fontString = Xist_UI:FontString(frame, fontClass),
            }
        else
            -- We've already allocated a FontString widget for this spot in the queue.
            -- We need to recycle it so we don't use infinite memory.

            item.isRecycled = true
            item.oldHeight = item.height or 0 -- remember height of previous FontString
        end
        -- Whether new or recycled we always want to keep the index updated.
        item.index = index
        return item
    end)
end


function Xist_UI_MessageFrame:AddMessage(text)
    local messageData = self:AllocateMessageData()
    local fontString = messageData.fontString

    -- Assign the text to the fontString, then FORCE the width to be the appropriate
    -- width.  Only then can we determine how much height it needs.
    fontString:SetText(text)
    fontString:SetPoint('BOTTOMLEFT', self, self.linePadding, self.lineSpacing)
    fontString:SetWidth(self:GetWidth() - self.linePadding - self.linePadding)

    -- Now let's see how much height was taken by this fontString
    messageData.height = fontString:GetHeight()

    -- Now that we know the message height, recompute the totalHeight of this
    -- frame with all of the messages.
    --
    -- Note that we may have recycled an old message if we're now over the
    -- message limit, in which case we deduct the height of the old recycled
    -- message before adding the height of the newly added message.

    local heightBefore = self.totalHeight -- for debugging below
    if messageData.isRecycled then
        -- we removed an old message from the display, so deduct its height.
        -- do not deduct the line spacing after it, as we'll want to keep
        -- that for the new message as well.
        self.totalHeight = self.totalHeight - messageData.oldHeight
    else
        -- we've added a brand new message, so add line spacing for it
        self.totalHeight = self.totalHeight + self.lineSpacing
    end
    -- add the new message height to the total
    self.totalHeight = self.totalHeight + messageData.height
    self:SetHeight(self.totalHeight)

    -- If the queue contains more than 1 element, then the fontString that comes
    -- right before this one needs to be re-anchored onto this fontString.

    if self.messageQueue:GetLength() > 1 then
        local lastItem = self.messageQueue:GetPreviousItem(messageData.index)
        local lastLabel = lastItem.fontString
        lastLabel:SetPoint('BOTTOMLEFT', fontString, 'TOPLEFT', 0, self.lineSpacing)
    end

    -- We cannot use DEBUG() here since debug messages go into a custom MessageFrame,
    -- which if it's not working is not at all useful.
    if protected.DebugEnabled then
        local heightAfter = self.totalHeight
        local heightDiff = heightAfter - heightBefore
        print('AddMessage heightBefore='.. heightBefore ..' heightAfter='.. heightAfter ..' delta='.. heightDiff)
    end
end


function Xist_UI_MessageFrame:DebugDump()
    local m1 = {
        nMsgs = self.messageQueue:GetLength(),
        tHeight = self.totalHeight,
    }
    local m2 = {}
    for item in self.messageQueue:Iterate() do
        local fs = item.fontString
        table.insert(m2, { w= fs:GetWidth(), h= fs:GetHeight(), H= item.height})
    end

    -- this method is called "DebugDump" but really we want to see this even when
    -- debugging is disabled for this class.  This is called when a user clicks a
    -- "show me info" button, so SHOW it, debugging enabled or not.
    MESSAGE('MF', m1)
    MESSAGE('Messages', unpack(m2))
end