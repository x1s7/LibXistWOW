
local ModuleName = "Xist_UI_ScrollingMessageFrame"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_ScrollingMessageFrame, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_ScrollingMessageFrame
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_ScrollingMessageFrame
Xist_UI_ScrollingMessageFrame = M

protected.DebugEnabled = true

local DEBUG = protected.DEBUG


function Xist_UI_ScrollingMessageFrame:InitializeScrollingMessageFrameWidget()
    self.isScrollingMessageFrameWidget = true

    local parent = self:GetParent()
    local topOffset = parent.contentOffset or 0
    local sidePadding = 0
    local bottomPadding = 0

    self:SetPoint('TOPLEFT', sidePadding, -topOffset)
    self:SetPoint('BOTTOMRIGHT', -sidePadding, bottomPadding)

    local messageFrame = Xist_UI:MessageFrame(self)
    local scrollFrame = Xist_UI:ScrollFrame(self, messageFrame)

    self.messageFrame = messageFrame
    self.scrollFrame = scrollFrame
end


function Xist_UI_ScrollingMessageFrame:SetMaxMessages(limit)
    self.messageFrame:SetMaxMessages(limit)
end


function Xist_UI_ScrollingMessageFrame:DebugDump()
    self.messageFrame:DebugDump()
    self.scrollFrame:DebugDump()
end


function Xist_UI_ScrollingMessageFrame:AddMessage(text)
    local wasScrolledToEnd = self.scrollFrame.slider:IsScrolledToEnd()

    self.messageFrame:AddMessage(text)
    self.scrollFrame:Redraw()

    if wasScrolledToEnd then
        self.scrollFrame.slider:ScrollToEnd()
    end
end
