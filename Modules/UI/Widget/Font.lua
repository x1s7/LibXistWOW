
local ModuleName = "Xist_UI_Widget_Font"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Font, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Font
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Font
Xist_UI_Widget_Font = M


local BLACK                 = { r=0, g=0, b=0, a=1 }
local YELLOW                = { r=1, g=1, b=0, a=1 }
local YELLOW8               = { r=0.8, g=0.8, b=0, a=1 }
local GREY6                 = { r=0.6, g=0.6, b=0.6, a=1 }
local GREY8                 = { r=0.8, g=0.8, b=0.8, a=1 }
local WHITE                 = { r=1, g=1, b=1, a=1 }


local inheritance = {'Xist_UI_Widget_Font'}

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
            default = WHITE,
            disabled = GREY8,
            highlight = BLACK,
        },
    },
    button = {
        color = {
            default = YELLOW,
            highlight = BLACK,
        },
    },
    contextMenu = {
        color = {
            default = YELLOW8,
        },
    },
    contextMenuTitle = {
        size = 14,
        color = {
            default = YELLOW,
        },
    },
    contextMenuOption = {
        color = {
            default = WHITE,
        },
    },
    messages = {
        justifyH = 'LEFT',
    },
    tableDataCell = {
        color = {
            default = GREY8,
        },
    },
    tableHeaderCell = {
        color = {
            default = YELLOW8,
        },
    },
    title = {
        size = 16,
        flags = 'OUTLINE',
        color = {
            default = YELLOW,
        },
    },
}


--- Report Xist__UIParent as the parent of all fonts.
--- since fonts dont natively have parents, but in our case it's useful to have,
--- assign Xist__UIParent as the explicit parent of all fonts.
--- @return Xist_UI_Widget
function Xist_UI_Widget_Font:GetParent()
    return Xist__UIParent
end


function Xist_UI_Widget_Font:SetParent()
    error('Do not assign a parent to a font; fonts are global widgets')
end


--- @return number
function Xist_UI_Widget_Font:GetFontHeight()
    local _, height = self:GetFont()
    return height
end


Xist_UI_Config:RegisterWidget('font', inheritance, settings, classes)
