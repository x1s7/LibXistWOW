
local ModuleName = "Xist_UI_Widget_Texture"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Texture, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Texture
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Texture
Xist_UI_Widget_Texture = M


local inheritance = {Xist_UI_Widget_Texture}

local settings = {
}

local classes = {
    slider = {
        file = [[Interface\Buttons\UI-SliderBar-Button-Vertical]],
        width = 32,
        height = 32,
    },
}


Xist_UI_Config:RegisterWidget('texture', inheritance, settings, classes)
