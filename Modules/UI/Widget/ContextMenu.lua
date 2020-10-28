
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

local inheritance = {'Xist_UI_Widget_ContextMenu'}

local settings = {
    parent = 'panel',
}

local classes = {
    default = {
        backdropClass = 'contextMenu',
        buttonClass = 'contextMenuOption',
        fontClass = 'contextMenuOption',
        labelClass = 'contextMenuOption',
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


local function OnContextMenuMouseUp(contextMenu, button)
    if button == 'RightButton' then
        contextMenu:Hide()
    end
end


local function OnContextMenuItemMouseUp(itemFrame, button)
    if button == 'RightButton' then
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
        itemFrame = Xist_UI:Button(self) -- Xist_UI:Label(self) -- Xist_UI:Button(self)
        itemFrame:SetText(itemConf.text)
        if itemConf.callback then
            local menu = self
            itemFrame:RegisterEvent('OnClick', function(frame, button)
                if button == 'LeftButton' then
                    if itemConf.callback(frame) == true then
                        menu:Hide()
                    end
                end
            end)
        end
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
    local widgetBorderWidth = Xist_UI:GetWidgetBorderWidth(self)

    DEBUG_CAT('InitializeMenuItems >>>>>>>>>>>>>>>>>>>', 'spacing=', spacing, 'widgetBorderWidth=', widgetBorderWidth)

    local items = {}
    local offsetTop = widgetBorderWidth + spacing.top
    local offsetLeft = widgetBorderWidth + spacing.left
    local offsetRight = widgetBorderWidth + spacing.right
    local offsetBottom = widgetBorderWidth + spacing.bottom
    local maxWidth = 0
    local itemFrame, width, height

    for i, itemConf in ipairs(options) do
        itemFrame = self:CreateMenuItem(itemConf)

        width = itemFrame:GetWidth()
        height = itemFrame:GetHeight()

        itemFrame:ClearAllPoints()
        itemFrame:SetPoint('TOPLEFT', offsetLeft, -offsetTop)

        itemFrame:EnableMouse(true)
        itemFrame:HookScript('OnMouseUp', OnContextMenuItemMouseUp)

        if width > maxWidth then
            maxWidth = width
        end

        -- AFTER checking the width then pin the right side
        itemFrame:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -offsetRight, -offsetTop -height)

        items[#items+1] = itemFrame
        offsetTop = offsetTop + height + spacing.vbetween

        DEBUG_CAT('InitializeMenuItems ['..i..']', {width=width, height=height, offset= offsetTop })
    end

    self.items = items

    width = maxWidth + offsetLeft + offsetRight
    height = offsetTop - spacing.vbetween + offsetBottom

    self:SetSize(width, height)

    DEBUG_CAT('InitializeMenuItems <<<<<<<<<<<<<<<<<<<', {width=width, height=height})
end


local function InitializeContextMenuWidget(widget, options)
    widget:InitializeMenuOptions(options)
    widget:EnableMouse(true) -- dont let mouse pass thru this frame
    widget:HookScript('OnMouseUp', OnContextMenuMouseUp)
    widget:GetParent():HookScript('OnMouseUp', function(_, button) widget:OnContextMenuMouseUp(button) end)
end


Xist_UI_Config:RegisterWidget('contextMenu', inheritance, settings, classes, InitializeContextMenuWidget)
