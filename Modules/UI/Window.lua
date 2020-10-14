
local ModuleName = "Xist_UI_Window"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Window, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Window
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Window
Xist_UI_Window = M


function Xist_UI_Window:InitializeWindowWidget(title)
    title = title or 'Undefined Title'

    local closeButton = self.closeButtonWidget

    local classConf = self:GetWidgetClassConfig()
    local titlePadding = classConf.titlePadding or 0
    local titleFontClass = classConf.titleFontClass or 'title'

    local titleFont = Xist_UI:FontString(self, titleFontClass)
    titleFont:SetText(title)
    titleFont:SetPoint('TOPLEFT', titlePadding, -titlePadding)
    titleFont:SetPoint('TOPRIGHT', -titlePadding -closeButton:GetWidth() -titlePadding, -titlePadding)

    -- let other code know where they can safely place other widgets to not cover up the header
    -- self.contentOffset was previously computed by Xist_UI_Dialog to be the close button height
    self.contentOffset = math.max(self.contentOffset, titleFont:GetHeight() + titlePadding + titlePadding)
end
