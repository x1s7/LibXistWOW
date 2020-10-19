
local ModuleName = "Xist_UI_Widget_Backdrop"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Backdrop, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Backdrop
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Backdrop
Xist_UI_Widget_Backdrop = M


local classes = {
    default = {
        backdrop = {
            bgFile = [[Interface\Buttons\WHITE8X8]],
            edgeFile = [[Interface\Buttons\WHITE8X8]],
            edgeSize = 1,
            tile = false,
            tileSize = 0,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        },
        borderColor = { r=0.9, g=0.9, b=0, a=0.9 },
        color = { r=0.05, g=0.05, b=0.05, a=0.9 },
    },
    borderless = {
        backdrop = {
            edgeFile = Xist_Config.DELETE,
            edgeSize = 0,
        },
    },
    contextMenu = {
        parent = 'default',
        borderColor = { r=1, g=1, b=0, a=0.8 },
        color = { r=0, g=.05, b=0, a=0.8 },
    },
    transparent = {
        backdrop = {
            bgFile = Xist_Config.DELETE,
            edgeFile = Xist_Config.DELETE,
            edgeSize = 0,
        },
    },
    slider = {
        backdrop = {
            bgFile = [[Interface\Buttons\UI-SliderBar-Background]],
            edgeFile = [[Interface\Buttons\UI-SliderBar-Border]],
            edgeSize = 8,
            tile = true,
            tileSize = 8,
            insets = { left = 3, right = 3, top = 6, bottom = 6 },
        },
    },
}


Xist_UI_Config:RegisterWidget('backdrop', nil, nil, classes)
