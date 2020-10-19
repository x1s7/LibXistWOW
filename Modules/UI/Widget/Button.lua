
local ModuleName = "Xist_UI_Widget_Button"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Button, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Button
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Button
Xist_UI_Widget_Button = M


local inheritance = { Xist_UI_Widget_Button}

local settings = {
    backdrop = true,
    clampedToScreen = true,
    strata = 'DIALOG',
}

local classes = {
    default = {
        backdropClass = 'button',
        fontClass = 'button',
    },
    contextMenu = {
        backdropClass = 'transparent',
        fontClass = 'contextMenu',
    },
}


function Xist_UI_Widget_Button:InitializeButtonWidget()
    self:SetDisabledFontObject(self:GetWidgetFontObject('disabled'))
    self:SetHighlightFontObject(self:GetWidgetFontObject('highlight'))
    self:SetNormalFontObject(self:GetWidgetFontObject('default'))
end


function Xist_UI_Widget_Button:GetTextHeight()
    return math.floor(self:_GetTextHeight() + 0.5)
end


function Xist_UI_Widget_Button:GetTextWidth()
    return math.floor(self:_GetTextWidth() + 0.5)
end


Xist_UI_Config:RegisterWidget('button', inheritance, settings, classes)
