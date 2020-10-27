
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
        backdropColor = { r=0.05, g=0.05, b=0.05, a=0.9 },
    },
    borderless = {
        backdrop = {
            edgeFile = Xist_Config.NIL,
            edgeSize = 0,
        },
    },
    button = {
        borderColor = { r=1, g=1, b=0, a=1 },
        backdropColor = { r=0.9, g=0, b=0, a=1 },
    },
    contextMenu = {
        borderColor = { r=1, g=1, b=0, a=0.9 },
        backdropColor = { r=0, g=0, b=0, a=0.9 },
    },
    contextMenuOption = {
        backdrop = Xist_Config.NIL,
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
    tableDataCell = {
        parent = 'borderless',
        backdropColor = { r=0, g=0, b=0, a=0 }, -- fully transparent
    },
    tableHeaderCell = {
        borderColor = { r=0.3, g=0.3, b=0, a=1 },
        backdropColor = { r=0.6, g=0.6, b=0, a=1 },
    },
    transparent = {
        parent = 'borderless',
        backdropColor = { r=0, g=0, b=0, a=0 },
    },
}


-- Backdrop colors, which aren't generally useful except in debugging for high contrast

classes.black   = { backdropColor = { r=0, g=0, b=0, a=1 } }
classes.blue    = { backdropColor = { r=0, g=0, b=1, a=1 } }
classes.green   = { backdropColor = { r=0, g=1, b=0, a=1 } }
classes.red     = { backdropColor = { r=1, g=0, b=0, a=1 } }
classes.white   = { backdropColor = { r=1, g=1, b=1, a=1 } }
classes.yellow  = { backdropColor = { r=1, g=1, b=0, a=1 } }


Xist_UI_Config:RegisterWidget('backdrop', nil, nil, classes)
