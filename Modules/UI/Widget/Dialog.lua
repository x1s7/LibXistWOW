
local ModuleName = "Xist_UI_Widget_Dialog"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Dialog, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Dialog
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Dialog
Xist_UI_Widget_Dialog = M


local inheritance = {Xist_UI_Widget_Dialog}

local settings = {
    parent = 'panel',
}

local classes = {
    default = {
        buttonPadding = 4,
    },
}


local function InitializeDialogWidget(widget)
    local classConf = widget:GetWidgetConfig()
    local buttonPadding = classConf.buttonPadding or 0

    Xist_UI:MakeWidgetDraggable(widget)

    local closeButton = Xist_UI:Button(widget)
    closeButton:SetText('X')
    closeButton:SetSize(16, 16)
    closeButton:SetPoint('TOPRIGHT', -buttonPadding, -buttonPadding)
    closeButton:HookScript('OnMouseUp', function() widget:Hide() end)

    widget.closeButtonWidget = closeButton

    -- let other code know where they can safely place other widgets to not cover up the close button
    widget.contentOffset = closeButton:GetHeight() + buttonPadding + buttonPadding
end


Xist_UI_Config:RegisterWidget('dialog', inheritance, settings, classes, InitializeDialogWidget)
