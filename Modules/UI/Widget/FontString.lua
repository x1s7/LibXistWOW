
local ModuleName = "Xist_UI_Widget_FontString"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_FontString, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_FontString
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_FontString
Xist_UI_Widget_FontString = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG


local inheritance = {Xist_UI_Widget_FontString}

local settings = {
}

local classes = {
    button = {
        fontClass = 'button',
    },
    contextMenu = {
        fontClass = 'contextMenu',
    },
    contextMenuTitle = {
        fontClass = 'contextMenuTitle',
    },
    messages = {
        fontClass = 'messages',
    },
    title = {
        fontClass = 'title',
    },
}


local function InitializeFontStringWidget(widget, colorCode)
    widget.widgetColorCode = colorCode

    local font = Xist_UI:GetFontObject(widget, nil, colorCode)
    widget:SetFontObject(font)
    widget:SetJustifyH(font:GetJustifyH())
    widget:SetJustifyV(font:GetJustifyV())

    --DEBUG("Initialize FontString", {class=widget.widgetClass, justifyH=font:GetJustifyH()})
end


Xist_UI_Config:RegisterWidget('fontString', inheritance, settings, classes, InitializeFontStringWidget)
