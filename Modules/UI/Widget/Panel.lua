
local ModuleName = "Xist_UI_Widget_Panel"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Panel, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Panel
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Panel
Xist_UI_Widget_Panel = M


local inheritance = {Xist_UI_Widget_Panel}

local settings = {
    parent = 'frame',
    backdrop = true,
    clampedToScreen = true,
    height = 200,
    strata = 'DIALOG',
    width = 200,
}

local classes = {
    default = {
        backdropClass = 'default',
        buttonClass = 'default',
        fontClass = 'default',
    },
}


Xist_UI_Config:RegisterWidget('panel', inheritance, settings, classes)
