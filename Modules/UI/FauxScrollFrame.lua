
local ModuleName = "Xist_UI_FauxScrollFrame"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_FauxScrollFrame, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_FauxScrollFrame
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_FauxScrollFrame
Xist_UI_FauxScrollFrame = M


local function OnVerticalScroll(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, self.widgetContentFrame:GetLineHeight(), self.WidgetScrollMessageContent)
end


function Xist_UI_FauxScrollFrame:InitializeFauxScrollFrameWidget(contentFrame)
    self.widgetContentFrame = contentFrame

    self:SetPoint('TOPLEFT', contentFrame)
    self:SetPoint('BOTTOMRIGHT', contentFrame)

    self:EnableMouse(true)
    self:EnableMouseWheel(true)

    self:SetScript('OnVerticalScroll', OnVerticalScroll)
end


function Xist_UI_FauxScrollFrame:WidgetScrollMessageContent()
    local contentFrame = self.widgetContentFrame

    local numMessages = contentFrame:GetNumMessages()
    local displayLines = contentFrame:GetNumVisibleLines()
    local lineHeight = contentFrame:GetLineHeight()

    local offset = FauxScrollFrame_GetOffset(self)
    local tmp = math.max(0, numMessages - displayLines - offset)
    contentFrame:SetScrollOffset(tmp)

    FauxScrollFrame_Update(self, numMessages, displayLines, lineHeight)
end
