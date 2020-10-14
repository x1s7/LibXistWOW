
local ModuleName = "Xist_UI_Label"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Label, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Label
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Label
Xist_UI_Label = M


function Xist_UI_Label:InitializeLabelWidget(colorCode)
    self.widgetColorCode = colorCode

    self.fontString = Xist_UI:FontString(self, self.widgetClass, self.widgetColorCode)
    self.fontString:SetPoint('TOPLEFT')
    self.fontString:SetPoint('BOTTOMRIGHT')
end


function Xist_UI_Label:SetText(text)
    self.fontString:SetText(text)
    -- recompute the width/height of the label based on the text
    self:SetWidth(self.fontString:GetWidth())
    self:SetHeight(self.fontString:GetHeight())
end


function Xist_UI_Label:GetFontObject()
    return self.fontString:GetFontObject()
end


function Xist_UI_Label:SetFontObject(font)
    self.fontString:SetFontObject(font)
end
