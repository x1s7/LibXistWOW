
local ModuleName = "Xist_UI_FontString"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_FontString, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_FontString
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_FontString
Xist_UI_FontString = M


function Xist_UI_FontString:InitializeFontStringWidget(colorCode)
    self.widgetColorCode = colorCode
    local font = self:GetWidgetFontObject(colorCode)
    self:SetFontObject(font)
    self:SetJustifyH(font:GetJustifyH())
    self:SetJustifyV(font:GetJustifyV())
end
