
local ModuleName = "Xist_UI_Widget_ContextMenu"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_ContextMenu, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_ContextMenu
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_ContextMenu
Xist_UI_Widget_ContextMenu = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local DEBUG_CAT = protected.DEBUG_CAT

local inheritance = {Xist_UI_Widget_ContextMenu}

local settings = {
    parent = 'panel',
}

local classes = {
    default = {
        backdropClass = 'contextMenu',
        buttonClass = 'contextMenu',
        fontClass = 'contextMenu',
        padding = {
            v = 2,
            h = 4,
        },
        spacing = {
            v = 2,
            h = 4,
            bottom = 4,
        },
        titleFontClass = 'contextMenuTitle',
    },
}


local function OnContextMenuItemMouseUp(itemFrame, button)
    local hide
    if button == 'LeftButton' then
        if itemFrame.menuItemConf.callback then
            hide = itemFrame.menuItemConf.callback() == true
        end
    elseif button == 'RightButton' then
        hide = true
    end
    if hide then
        itemFrame.menu:Hide()
    end
end


function Xist_UI_Widget_ContextMenu:OnContextMenuMouseUp(button)
    if button == 'RightButton' then
        local uiScale = UIParent:GetScale()
        local cursorX, cursorY = GetCursorPosition()

        cursorX = cursorX / uiScale
        cursorY = cursorY / uiScale

        self:ClearAllPoints()

        if self:IsShown() then
            self:Hide()
        else
            self:SetPoint('TOPLEFT', nil, 'BOTTOMLEFT', cursorX, cursorY)
            self:Show()
        end
    end
end


function Xist_UI_Widget_ContextMenu:CreateMenuItem(itemConf)
    local env = self:GetWidgetEnvironment()
    local itemFrame

    if itemConf.title then
        itemFrame = Xist_UI:Label(self, env:GetEnv('titleFontClass'))
        itemFrame:SetText(itemConf.title)
    elseif itemConf.text then
        itemFrame = Xist_UI:Button(self)
        itemFrame:SetText(itemConf.text)
    else
        error('Unsupported ContextMenu item config: '.. Xist_Util.Args2StringLiteral(itemConf))
    end

    itemFrame.menu = self
    itemFrame.menuItemConf = itemConf

    return itemFrame
end


function Xist_UI_Widget_ContextMenu:InitializeMenuOptions(options)
    local env = self:GetWidgetEnvironment()
    local spacing = env:GetSpacing()

    DEBUG_CAT('InitializeMenuItems >>>>>>>>>>>>>>>>>>>', 'spacing=', spacing)

    local items = {}
    local offset = spacing.top
    local maxWidth = 0
    local itemFrame, width, height

    for i, itemConf in ipairs(options) do
        itemFrame = self:CreateMenuItem(itemConf)

        width = itemFrame:GetWidth()
        height = itemFrame:GetHeight()

        itemFrame:ClearAllPoints()
        itemFrame:SetPoint('TOPLEFT', spacing.left, -offset)

        itemFrame:EnableMouse(true)
        itemFrame:HookScript('OnMouseUp', OnContextMenuItemMouseUp)

        if width > maxWidth then
            maxWidth = width
        end

        -- AFTER checking the width then pin the right side
        itemFrame:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -spacing.right, -offset-height)

        items[#items+1] = itemFrame
        offset = offset + height + spacing.vbetween

        DEBUG_CAT('InitializeMenuItems ['..i..']', {width=width, height=height, offset=offset})
    end

    self.items = items

    width = maxWidth + spacing.left + spacing.right
    height = offset - spacing.vbetween + spacing.bottom

    self:SetSize(width, height)

    DEBUG_CAT('InitializeMenuItems <<<<<<<<<<<<<<<<<<<', {width=width, height=height})
end


local function InitializeContextMenuWidget(widget, options)
    widget:InitializeMenuOptions(options)
    widget:EnableMouse(true) -- dont let mouse pass thru this frame
    widget:GetParent():HookScript('OnMouseUp', function(_, button) widget:OnContextMenuMouseUp(button) end)
end


Xist_UI_Config:RegisterWidget('contextMenu', inheritance, settings, classes, InitializeContextMenuWidget)
