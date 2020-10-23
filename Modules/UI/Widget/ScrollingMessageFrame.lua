
local ModuleName = "Xist_UI_Widget_ScrollingMessageFrame"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_ScrollingMessageFrame, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_ScrollingMessageFrame
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_ScrollingMessageFrame
Xist_UI_Widget_ScrollingMessageFrame = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG


local inheritance = {Xist_UI_Widget_ScrollingMessageFrame}

local settings = {
    parent = 'frame',
    strata = 'DIALOG',
}

local classes = {
}


local function InitializeScrollingMessageFrameWidget(widget)
    widget.isScrollingMessageFrameWidget = true

    local parent = widget:GetParent()
    local topOffset = parent.contentOffset or 0
    local sidePadding = 0
    local bottomPadding = 0

    widget:SetPoint('TOPLEFT', sidePadding, -topOffset)
    widget:SetPoint('BOTTOMRIGHT', -sidePadding, bottomPadding)

    local messageFrame = Xist_UI:MessageFrame(widget)
    local scrollFrame = Xist_UI:ScrollFrame(widget, messageFrame)

    widget.messageFrame = messageFrame
    widget.scrollFrame = scrollFrame
end


function Xist_UI_Widget_ScrollingMessageFrame:SetMaxMessages(limit)
    self.messageFrame:SetMaxMessages(limit)
end


function Xist_UI_Widget_ScrollingMessageFrame:DebugDump()
    self.messageFrame:DebugDump()
    self.scrollFrame:DebugDump()
end


function Xist_UI_Widget_ScrollingMessageFrame:AddMessage(text)
    local wasScrolledToEnd = self.scrollFrame.slider:IsScrolledToEnd()

    self.messageFrame:AddMessage(text)
    self.scrollFrame:Redraw()

    if wasScrolledToEnd then
        self.scrollFrame.slider:ScrollToEnd()
    end
end


Xist_UI_Config:RegisterWidget('scrollingMessageFrame', inheritance, settings, classes, InitializeScrollingMessageFrameWidget)
