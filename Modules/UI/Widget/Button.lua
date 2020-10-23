
local ModuleName = "Xist_UI_Widget_Button"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Button, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Button
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Button
Xist_UI_Widget_Button = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local DEBUG_CAT = protected.DEBUG_CAT


local inheritance = {Xist_UI_Widget_Button}

local settings = {
    clampedToScreen = true,
    strata = 'DIALOG',
}

local classes = {
    default = {
        fontClass = 'button',
        highlightTextureClass = 'buttonHighlight',
        normalTextureClass = 'buttonNormal',
        padding = 2,
        pushedTextureClass = 'buttonPushed',
        registerClicks = {'LeftButton', 'RightButton'},
    },
    addonSettingsButton = {
        padding = 4,
    },
    contextMenu = {
        fontClass = 'contextMenu',
        normalTextureClass = 'buttonTransparent',
        padding = {
            h = 6,
            v = 2,
        },
    },
    tableHeaderCell = {
        fontClass = 'tableHeaderCell',
    },
    tableDataCell = {
        fontClass = 'default',
    },
}


local function InitializeButtonWidget(widget)
    local env = widget:GetWidgetEnvironment()
    DEBUG('InitializeButtonWidget', widget.widgetClass, env:GetEnvironment())

    widget:SetDisabledFontObject(Xist_UI:GetFontObject(widget, nil, 'disabled'))
    widget:SetHighlightFontObject(Xist_UI:GetFontObject(widget, nil, 'highlight'))
    widget:SetNormalFontObject(Xist_UI:GetFontObject(widget, nil, 'default'))

    widget.widgetHighlightTexture = Xist_UI:Texture(widget, env:GetEnv('highlightTextureClass'))
    widget.widgetNormalTexture = Xist_UI:Texture(widget, env:GetEnv('normalTextureClass'))
    widget.widgetPushedTexture = Xist_UI:Texture(widget, env:GetEnv('pushedTextureClass'))

    widget:SetNormalTexture(widget.widgetNormalTexture)

    local clicks = env:GetEnv('registerClicks')
    if clicks and #clicks > 0 then
        local allClicks = {}
        for _, click in ipairs(clicks) do
            allClicks[1+#allClicks] = click ..'Up'
            allClicks[1+#allClicks] = click ..'Down'
        end
        DEBUG('RegisterForClicks', allClicks)
        widget:RegisterForClicks(unpack(allClicks))
        widget:HookScript('OnMouseUp', widget.HandleOnMouseUp)
        widget:HookScript('OnMouseDown', widget.HandleOnMouseDown)
    end

    widget:HookScript('OnEnter', widget.HandleOnEnter)
    widget:HookScript('OnLeave', widget.HandleOnLeave)
end


function Xist_UI_Widget_Button:SetFixedSize(width, height)
    self.widgetFixedSize = true
    self:SetSize(width, height)
end


function Xist_UI_Widget_Button:SetText(text)
    self:_SetText(text)
    if not self.widgetFixedSize then
        local env = self:GetWidgetEnvironment()
        local padding = env:GetPadding()
        DEBUG_CAT('SetText', {text=text}, 'padding=', padding)
        self:SetWidth(padding.left + self:GetTextWidth() + padding.right)
        self:SetHeight(padding.top + self:GetTextHeight() + padding.bottom)
    end
end


function Xist_UI_Widget_Button:GetTextHeight()
    return math.floor(self:_GetTextHeight() + 0.5)
end


function Xist_UI_Widget_Button:GetTextWidth()
    return math.floor(self:_GetTextWidth() + 0.5)
end


function Xist_UI_Widget_Button:HandleOnMouseDown(button)
    --DEBUG('Button:HandleOnMouseDown', button)
end


function Xist_UI_Widget_Button:HandleOnMouseUp(button)
    --DEBUG('Button:HandleOnMouseUp', button)
end


function Xist_UI_Widget_Button:HandleOnEnter()
    if self:IsEnabled() then
        self:SetNormalTexture(self.widgetHighlightTexture)
    end
end


function Xist_UI_Widget_Button:HandleOnLeave()
    if self:IsEnabled() then
        self:SetNormalTexture(self.widgetNormalTexture)
    end
end


Xist_UI_Config:RegisterWidget('button', inheritance, settings, classes, InitializeButtonWidget)
