
local ModuleName = "Xist_UI_Widget_Label"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Label, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Label
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Label
Xist_UI_Widget_Label = M

protected.DebugEnabled = true

local DEBUG_CAT = protected.DEBUG_CAT


local inheritance = {'Xist_UI_Widget_Label'}

local settings = {
    parent = 'panel',
}

local classes = {
    default = {
        backdropClass = 'transparent',
        padding = 4,
    },
    title = {
        fontClass = 'title',
    },
    contextMenuTitle = {
        fontClass = 'contextMenuTitle',
    },
    contextMenuOption = {
        backdropClass = 'transparent',
        fontClass = 'contextMenuOption',
    },
}


local function InitializeLabelWidget(widget, colorCode)
    local env = widget:GetWidgetEnvironment()
    local padding = env:GetPadding()

    widget.widgetColorCode = colorCode or 'default'
    widget.widgetFontClass = Xist_UI:GetWidgetClass(widget, 'font')
    widget.widgetPadding = padding

    local fontString = Xist_UI:FontString(widget, widget.widgetFontClass, widget.widgetColorCode)

    fontString:SetPoint('TOPLEFT', padding.left, -padding.top)
    fontString:SetPoint('BOTTOMRIGHT', -padding.right, padding.bottom)

    widget.fontString = fontString
end


function Xist_UI_Widget_Label:SetFixedHeight(height)
    self.widgetFixedHeight = true
    self:SetHeight(height)
end


function Xist_UI_Widget_Label:SetFixedWidth(width)
    self.widgetFixedWidth = true
    self:SetWidth(width)
end


function Xist_UI_Widget_Label:SetFixedSize(width, height)
    self.widgetFixedWidth = true
    self.widgetFixedHeight = true
    self:SetSize(width, height)
end


function Xist_UI_Widget_Label:GetTextWidth()
    return self.fontString:GetWidth()
end


function Xist_UI_Widget_Label:GetTextHeight()
    return self.fontString:GetHeight()
end


function Xist_UI_Widget_Label:SetText(text)
    self.fontString:SetText(text)

    -- adjust label size to include padding
    local padding = self.widgetPadding
    local textWidth = self:GetTextWidth()
    local textHeight = self:GetTextHeight()

    if not self.widgetFixedWidth then
        self:SetWidth(textWidth + padding.left + padding.right)
    end

    if not self.widgetFixedHeight then
        self:SetHeight(textHeight + padding.top + padding.bottom)
    end

    if protected.DebugEnabled then
        local r,g,b,a = self.fontString:GetFontObject():GetTextColor()
        local fontDump = {r=r, g=g, b=b, a=a, fontClass=self.widgetFontClass}
        DEBUG_CAT('Label.SetText', {text=text, width=textWidth, height=textHeight}, fontDump)
    end
end


function Xist_UI_Widget_Label:GetFontObject()
    return self.fontString:GetFontObject()
end


function Xist_UI_Widget_Label:SetFontObject(font)
    self.fontString:SetFontObject(font)
end


Xist_UI_Config:RegisterWidget('label', inheritance, settings, classes, InitializeLabelWidget)
