
local ModuleName = "Xist_UI_Widget_Window"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Window, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Window
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Window
Xist_UI_Widget_Window = M


local inheritance = {'Xist_UI_Widget_Dialog', 'Xist_UI_Widget_Window'}

local settings = {
    parent = 'panel',
    anchors = {{'CENTER'}}, -- todo move to window class config
}

local classes = {
    default = {
        backdropClass = 'default',
        padding = 2,
        spacing = 4,
        titleFontClass = 'title',
        titlePadding = 4,
    },
}


local function InitializeWindowWidget(widget, title)
    title = title or 'Undefined Title'

    -- we want to initialize ourself as a dialog and then apply window settings
    local initDialog = Xist_UI_Config:GetWidgetInitializeMethod('dialog')
    initDialog(widget)

    local closeButton = widget.closeButtonWidget

    local env = widget:GetWidgetEnvironment()
    local spacing = env:GetSpacing()

    local titleFont = Xist_UI:FontString(widget, env:GetEnv('titleFontClass'))
    titleFont:SetText(title)
    titleFont:SetPoint('TOPLEFT', spacing.left, -spacing.top)
    titleFont:SetPoint('RIGHT', closeButton, 'LEFT', -spacing.hbetween, 0)

    -- let other code know where they can safely place other widgets to not cover up the header
    -- self.contentOffset was previously computed by Xist_UI_Widget_Dialog to be the close button height
    widget.contentOffset = math.max(widget.contentOffset, titleFont:GetHeight() + spacing.top + spacing.vbetween)
end


Xist_UI_Config:RegisterWidget('window', inheritance, settings, classes, InitializeWindowWidget)
