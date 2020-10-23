
local ModuleName = "Xist_UI_Widget_Font"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Font, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Font
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Font
Xist_UI_Widget_Font = M


local inheritance = {Xist_UI_Widget_Font}

local settings = {
}

local classes = {
    default = {
        family = [[Fonts\FRIZQT__.ttf]],
        size = 12,
        flags = '', -- OUTLINE,THICKOUTLINE,MONOCHROME
        justifyH = 'CENTER',
        justifyV = 'MIDDLE',
        color = {
            default = { r=1, g=1, b=1, a=1 },
            disabled = { r=0.6, g=0.6, b=0.6, a=1 },
            highlight = { r=1, g=1, b=0, a=1 },
        },
    },
    button = {
        color = {
            default = { r=1, g=1, b=0, a=1 },
            highlight = { r=0, g=0, b=0, a=1 },
        },
    },
    contextMenu = {
        color = {
            default = { r=0.8, g=0.8, b=0, a=1 },
        },
    },
    contextMenuTitle = {
        size = 14,
        color = {
            default = { r=1, g=1, b=1, a=1 },
        },
    },
    messages = {
        justifyH = 'LEFT',
    },
    tableDataCell = {
    },
    tableHeaderCell = {
        color = {
            default = { r=0.2, g=0.2, b=0.2, a=1 },
        },
    },
    title = {
        size = 16,
        flags = 'OUTLINE',
        color = {
            default = { r=1, g=1, b=0, a=1 },
        },
    },
}


function Xist_UI_Widget_Font:GetFontHeight()
    local _, height = self:GetFont()
    return height
end


Xist_UI_Config:RegisterWidget('font', inheritance, settings, classes)
