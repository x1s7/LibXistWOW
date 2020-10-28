
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
        pushedTexture = 'buttonPushed',
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

    widget.eventHandler = Xist_EventHandler:NewWidgetHandler(widget, {
        'OnClick', 'OnMouseUp', 'OnMouseDown',
        'OnEnable', 'OnDisable',
        'OnMouseEnter', 'OnMouseLeave'
    })

    widget.isMouseDown = false
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

    widget.pushedTexture = Xist_UI:Texture(widget, env:GetEnv('pushedTexture'))
    widget.pushedTexture:Hide()

    widget:HookScript('OnEnter', Xist_UI_Widget_Button.HandleOnEnter)
    widget:HookScript('OnLeave', Xist_UI_Widget_Button.HandleOnLeave)

    widget:SetEnabled(true)
end


function Xist_UI_Widget_Button:RegisterEvent(eventName, callback)
    self.eventHandler:RegisterEvent(eventName, callback)
end


function Xist_UI_Widget_Button:RegisterForClicks(...)
    DEBUG_CAT('RegisterForClicks', ...)
end


function Xist_UI_Widget_Button:IsEnabled()
    return self.enabled == true
end


function Xist_UI_Widget_Button:SetEnabled(enabled)
    if self.enabled ~= enabled then
        -- The enabled state is changing
        self.enabled = enabled
        if enabled then
            self.disabledTexture:Hide()
            self.fontString:Enable()
            -- if it gets enabled while the mouse is hovering, show the highlight texture
            if self.isMouseHovering then
                self.highlightTexture:Show()
                self.fontString:Highlight()
            end
            self.eventHandler:TriggerEvent('OnEnable', self)
        else
            self.disabledTexture:Show()
            self.fontString:Disable()
            -- if it gets disabled while the mouse is hovering, hide the highlight texture
            self.highlightTexture:Hide()
            -- in case it was pushed when it got disabled, disable pushed texture
            self.pushedTexture:Hide()
            self.eventHandler:TriggerEvent('OnDisable', self)
        end
    end
end


function Xist_UI_Widget_Button:Enable()
    self:SetEnabled(true)
end


function Xist_UI_Widget_Button:Disable()
    self:SetEnabled(false)
end


function Xist_UI_Widget_Button:HandleOnMouseDown(button)
    self.isMouseDown = true

    if self:IsEnabled() then
        --DEBUG('Button:HandleOnMouseDown', button)
        self.pushedTexture:Show() -- button is now pushed
        self.highlightTexture:Hide() -- don't highlight while showing pushed

        self.eventHandler:TriggerEvent('OnMouseDown', self, button)
    end
end


function Xist_UI_Widget_Button:HandleOnMouseUp(button)
    self.isMouseDown = false

    if self:IsEnabled() then
        --DEBUG('Button:HandleOnMouseUp', button)
        self.pushedTexture:Hide() -- button is no longer pushed
        if self.isMouseHovering then
            self.highlightTexture:Show() -- mouse is hovering, show highlight
        end

        -- Register OnMouseUp events regardless of whether the event happened on top of the button or not
        self.eventHandler:TriggerEvent('OnMouseUp', self, button)

        -- Only register the OnClick event to callers if the mouse up happened OVER THE TOP OF the button.
        if self.isMouseHovering then
            self.eventHandler:TriggerEvent('OnClick', self, button)
        end
    end
end


function Xist_UI_Widget_Button:HandleOnEnter()
    self.isMouseHovering = true

    if self:IsEnabled() then
        self.fontString:Highlight()
        if self.isMouseDown then
            self.pushedTexture:Show() -- mouse is still down, reactivate pushed
        else
            self.highlightTexture:Show() -- mouse isn't down, highlight
        end

        self.eventHandler:TriggerEvent('OnMouseEnter', self)
    end
end


function Xist_UI_Widget_Button:HandleOnLeave()
    self.isMouseHovering = false

    if self:IsEnabled() then
        self.fontString:Unhighlight()
        self.highlightTexture:Hide()
        self.pushedTexture:Hide() -- in case the button was pushed, show that now it is not

        self.eventHandler:TriggerEvent('OnMouseLeave', self)
    end
end


Xist_UI_Config:RegisterWidget('button', inheritance, settings, classes, InitializeButtonWidget)
