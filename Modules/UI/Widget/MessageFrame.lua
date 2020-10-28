
local ModuleName = "Xist_UI_Widget_MessageFrame"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_MessageFrame, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_MessageFrame
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_MessageFrame
Xist_UI_Widget_MessageFrame = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local MESSAGE = protected.MESSAGE


local inheritance = {'Xist_UI_Widget_MessageFrame'}

local settings = {
    parent = 'panel',
}

local classes = {
    default = {
        backdropClass = 'transparent',
        fontClass = 'messages',
        maxLines = 50,
        spacing = {
            vbetween = 2,
            bottom = 2,
        },
    },
}


local function InitializeMessageFrameWidget(widget)
    local env = widget:GetWidgetEnvironment()
    local font = Xist_UI:GetFontObject(widget)

    widget.fontHeight = font:GetFontHeight()
    widget.messageQueue = Xist_Queue:New(env:GetEnv('maxLines') or 10)
    widget.spacing = env:GetSpacing()
    widget.totalHeight = 0
end


--- Get the maximum number of messages kept in memory.
--- @return number
function Xist_UI_Widget_MessageFrame:GetMaxMessages()
    return self.messageQueue:GetMaxLength()
end


--- Set the maximum number of messages to store in memory.
--- @param limit number
function Xist_UI_Widget_MessageFrame:SetMaxMessages(limit)
    self.messageQueue:SetMaxLength(limit)
end


--- Allocate space to hold message data.
--- This uses a Xist_Queue to ensure that we don't allocate infinite numbers of message data,
--- and instead we keep memory usage to a minimum.
--- @return table
function Xist_UI_Widget_MessageFrame:AllocateMessageData()
    -- create new font string if needed, else reuse existing one
    local widget = self
    return self.messageQueue:Allocate(function(item, index)
        if not item then
            -- this spot in the queue is currently empty.
            -- Allocate a new FontString widget.

            local env = widget:GetWidgetEnvironment()
            local fontClass = env:GetEnv('fontClass', widget.widgetClass) or 'default'
            item = {
                fontString = Xist_UI:FontString(widget, fontClass),
            }
        else
            -- We've already allocated a FontString widget for this spot in the queue.
            -- We need to recycle it so we don't use infinite memory.

            item.isRecycled = true
        end
        -- Whether new or recycled we always want to keep the index updated.
        item.index = index
        return item
    end)
end


--- Add a message to the frame.
--- If/when you add more than the max number of messages, old messages are "forgotten" from the display.
--- @param text string The text of the message
function Xist_UI_Widget_MessageFrame:AddMessage(text)
    local messageData = self:AllocateMessageData()
    local fontString = messageData.fontString

    -- Assign the text to the fontString, then FORCE the width to be the appropriate
    -- width.  Only then can we determine how much height it needs.
    fontString:SetText(text)
    fontString:SetPoint('BOTTOMLEFT', self, self.spacing.left, self.spacing.bottom)
    fontString:SetWidth(self:GetWidth() - self.spacing.left - self.spacing.right)

    -- Now let's see how much height was taken by this fontString
    local deletedMessageHeight = messageData.height or 0
    messageData.height = fontString:GetHeight()

    -- Now that we know the message height, recompute the totalHeight of this
    -- frame with all of the messages.
    --
    -- Note that we may have recycled an old message if we're now over the
    -- message limit, in which case we deduct the height of the old recycled
    -- message in addition to adding the height of the newly added message.

    if deletedMessageHeight > 0 then
        -- we removed a message to keep the queue at a max number of messages.
        -- remove the height of this message AND the vbetween space it used.
        self.totalHeight = self.totalHeight - deletedMessageHeight - self.spacing.vbetween
    end

    -- add the new message height to the total
    self.totalHeight = self.totalHeight + messageData.height + self.spacing.bottom

    self:SetHeight(self.totalHeight)

    -- If the queue contains more than 1 element, then the fontString that comes
    -- right before this one needs to be re-anchored onto this fontString.

    local lastItem = self.messageQueue:GetPreviousItem(messageData.index)
    if lastItem then
        lastItem.fontString:SetPoint('BOTTOMLEFT', fontString, 'TOPLEFT', 0, self.spacing.vbetween)
        -- the last item is no longer at the bottom, and is now spaced at vbetween px
        -- above the newly added message.  Adjust total height for the spacing difference,
        -- if there is any.
        self.totalHeight = self.totalHeight - self.spacing.bottom + self.spacing.vbetween
    end
end


--- Dump debug info.
--- This isn't ordinarily useful you're trying to debug scrolling.
function Xist_UI_Widget_MessageFrame:DebugDump()
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


Xist_UI_Config:RegisterWidget('messageFrame', inheritance, settings, classes, InitializeMessageFrameWidget)
