
local ModuleName = "Xist_UI_Button"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Button, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Button
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Button
Xist_UI_Button = M


function Xist_UI_Button:InitializeButtonWidget()
    local classConf = self:GetWidgetClassConfig()

    local fontClass = classConf.fontClass or self.widgetClass or 'default'

    self:SetDisabledFontObject(self:GetFontByClass(fontClass, 'disabled'))
    self:SetHighlightFontObject(self:GetFontByClass(fontClass, 'highlight'))
    self:SetNormalFontObject(self:GetFontByClass(fontClass, 'default'))
end


function Xist_UI_Button:GetTextHeight()
    return math.floor(self:_GetTextHeight() + 0.5)
end


function Xist_UI_Button:GetTextWidth()
    return math.floor(self:_GetTextWidth() + 0.5)
end
