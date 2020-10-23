
local ModuleName = "Xist_UI_Widget_Label"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Label, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Label
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Label
Xist_UI_Widget_Label = M


local inheritance = {Xist_UI_Widget_Label}

local settings = {
    parent = 'panel',
}

local classes = {
    title = {
        backdropClass = 'transparent',
        fontClass = 'title',
    },
    contextMenuTitle = {
        backdropClass = 'transparent',
        fontClass = 'contextMenuTitle',
    },
}


local function InitializeLabelWidget(widget, colorCode)
    local fontClass = Xist_UI:GetWidgetClass(widget, 'font')

    widget.fontString = Xist_UI:FontString(widget, fontClass, colorCode)
    widget.widgetColorCode = colorCode
end


function Xist_UI_Widget_Label:SetText(text)
    self.fontString:SetText(text)
    -- recompute the width/height of the label based on the text
    local env = self:GetWidgetEnvironment()
    local padding = env:GetPadding()

    -- clear points so fontString will tell us the real text sizes
    self.fontString:ClearAllPoints()

    -- assign label size with padding
    self:SetWidth(self.fontString:GetWidth() + padding.left + padding.right)
    self:SetHeight(self.fontString:GetHeight() + padding.top + padding.bottom)

    -- re-anchor font string to preserve padding
    self.fontString:SetPoint('TOPLEFT', padding.left, -padding.top)
    self.fontString:SetPoint('BOTTOMRIGHT', -padding.right, padding.bottom)
end


function Xist_UI_Widget_Label:GetFontObject()
    return self.fontString:GetFontObject()
end


function Xist_UI_Widget_Label:SetFontObject(font)
    self.fontString:SetFontObject(font)
end


Xist_UI_Config:RegisterWidget('label', inheritance, settings, classes, InitializeLabelWidget)
