
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
local DEBUG_CAT = protected.DEBUG_CAT


local inheritance = {'Xist_UI_Widget_FontString'}

local settings = {
}

local classes = {
    default = {
        backdropClass = 'transparent',
        fontClass = 'default',
    },
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
    local fontClass = Xist_UI:GetWidgetClass(widget, 'font')

    widget.widgetFontClass = fontClass
    widget.widgetColorCode = colorCode or 'default'

    widget.widgetNormalFontObject = Xist_UI:GetFontObject(widget, fontClass, 'default')
    widget.widgetDisabledFontObject = Xist_UI:GetFontObject(widget, fontClass, 'disabled')
    widget.widgetHighlightFontObject = Xist_UI:GetFontObject(widget, fontClass, 'highlight')

    if colorCode == 'highlight' then
        widget:SetFontObject(widget.widgetHighlightFontObject)
    elseif colorCode == 'disabled' then
        widget:SetFontObject(widget.widgetDisabledFontObject)
    else
        widget:SetFontObject(widget.widgetNormalFontObject)
    end
end


function Xist_UI_Widget_FontString:SetFontObject(font)
    self:_SetFontObject(font)
    self:SetJustifyH(font:GetJustifyH())
    self:SetJustifyV(font:GetJustifyV())
end


function Xist_UI_Widget_FontString:SetDisabledFontObject(font)
    self.widgetDisabledFontObject = font
end


function Xist_UI_Widget_FontString:SetHighlightFontObject(font)
    self.widgetHighlightFontObject = font
end


function Xist_UI_Widget_FontString:Disable()
    self:SetFontObject(self.widgetDisabledFontObject)
end


function Xist_UI_Widget_FontString:Enable()
    self:SetFontObject(self.widgetNormalFontObject)
end


function Xist_UI_Widget_FontString:Highlight()
    self:SetFontObject(self.widgetHighlightFontObject)
end


function Xist_UI_Widget_FontString:Unhighlight()
    self:SetFontObject(self.widgetNormalFontObject)
end


Xist_UI_Config:RegisterWidget('fontString', inheritance, settings, classes, InitializeFontStringWidget)
