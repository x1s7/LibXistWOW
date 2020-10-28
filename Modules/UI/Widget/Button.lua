
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


local inheritance = {'Xist_UI_Widget_Label', 'Xist_UI_Widget_Button'}

local settings = {
}

local classes = {
    default = {
        backdropClass = 'button',
        disabledTexture = 'buttonDisabled',
        fontClass = 'button',
        highlightTexture = 'buttonHighlight',
        padding = 4,
        registerClicks = { 'LeftButton', 'RightButton' }
    },
    contextMenuOption = {
        backdropClass = 'transparent',
        fontClass = 'contextMenuOption',
        padding = {
            v = 2,
            h = 6,
        },
    },
}


local function InitializeButtonWidget(widget)
    local env = widget:GetWidgetEnvironment()
    DEBUG_CAT('InitializeButtonWidget '.. widget.widgetClass, env:GetAll())

    -- we want to initialize ourself as a label and then apply button settings
    local initLabel = Xist_UI_Config:GetWidgetInitializeMethod('label')
    initLabel(widget)

    widget.isMouseHovering = false

    widget:EnableMouse(true)

    local clickButtons = env:GetEnv('registerClicks')
    if clickButtons and #clickButtons > 0 then
        local allClicks = {}
        for _, button in ipairs(clickButtons) do
            allClicks[1+#allClicks] = button ..'Up'
            allClicks[1+#allClicks] = button ..'Down'
        end
        widget:RegisterForClicks(unpack(allClicks))
    end

    widget:HookScript('OnMouseUp', Xist_UI_Widget_Button.HandleOnMouseUp)
    widget:HookScript('OnMouseDown', Xist_UI_Widget_Button.HandleOnMouseDown)

    widget.disabledTexture = Xist_UI:Texture(widget, env:GetEnv('disabledTexture'))
    widget.disabledTexture:Hide()

    widget.highlightTexture = Xist_UI:Texture(widget, env:GetEnv('highlightTexture'))
    widget.highlightTexture:Hide()

    widget:HookScript('OnEnter', Xist_UI_Widget_Button.HandleOnEnter)
    widget:HookScript('OnLeave', Xist_UI_Widget_Button.HandleOnLeave)

    widget:SetEnabled(true)
end


function Xist_UI_Widget_Button:RegisterForClicks(...)
    DEBUG_CAT('RegisterForClicks', ...)
end


function Xist_UI_Widget_Button:IsEnabled()
    return self.enabled == true
end


function Xist_UI_Widget_Button:SetEnabled(enabled)
    self.enabled = enabled
    if enabled then
        self.disabledTexture:Hide()
        self.fontString:Enable()
        -- if it gets enabled while the mouse is hovering, show the highlight texture
        if self.isMouseHovering then
            self.highlightTexture:Show()
            self.fontString:Highlight()
        end
    else
        self.disabledTexture:Show()
        self.fontString:Disable()
        -- if it gets disabled while the mouse is hovering, hide the highlight texture
        self.highlightTexture:Hide()
    end
end


function Xist_UI_Widget_Button:Enable()
    self:SetEnabled(true)
end


function Xist_UI_Widget_Button:Disable()
    self:SetEnabled(false)
end


function Xist_UI_Widget_Button:HandleOnMouseDown(button)
    if self:IsEnabled() then
        --DEBUG('Button:HandleOnMouseDown', button)
        if self.OnMouseDown then
            self:OnMouseDown(button)
        end
    end
end


function Xist_UI_Widget_Button:HandleOnMouseUp(button)
    if self:IsEnabled() then
        --DEBUG('Button:HandleOnMouseUp', button)
        if self.OnMouseUp then
            self:OnMouseUp(button)
        end
        if self.OnClick then
            self:OnClick(button)
        end
    end
end


function Xist_UI_Widget_Button:HandleOnEnter()
    self.isMouseHovering = true

    if self:IsEnabled() then
        self.highlightTexture:Show()
        self.fontString:Highlight()
    end
end


function Xist_UI_Widget_Button:HandleOnLeave()
    self.isMouseHovering = false

    if self:IsEnabled() then
        self.highlightTexture:Hide()
        self.fontString:Unhighlight()
    end
end


Xist_UI_Config:RegisterWidget('button', inheritance, settings, classes, InitializeButtonWidget)
