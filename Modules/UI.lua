
local ModuleName = "Xist_UI"
local ModuleVersion = 1

-- If some other addon installed Xist_UI, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI
Xist_UI = M

protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local WARNING = protected.WARNING

-- a full screen frame to be the parent of all Xist_UI elements
-- this way we can easily hide them all in combat, for example
local TopLevelFrame = CreateFrame('Frame', 'Xist_UI__UIParent', UIParent)

TopLevelFrame.widgetType = 'frame'
TopLevelFrame.widgetClass = 'default'

TopLevelFrame:SetPoint('TOPLEFT')
TopLevelFrame:SetPoint('BOTTOMRIGHT')
TopLevelFrame:Show()

Xist_UI.UIParent = TopLevelFrame


--- Create a Font object.
--- Read settings from the config to initialize the object.
--- @param config Xist_Config
--- @param class string
--- @param colorCode string
--- @return Font
function Xist_UI:GetFontObject(config, class, colorCode)
    class = class or 'default'
    colorCode = colorCode or 'default'

    local fontClasses = config:GetKey({'fontClasses'})
    if not fontClasses then
        error('No fontClasses defined in config')
    end

    local fontConf = fontClasses.default
    if not fontConf then
        error('No fontClasses.default defined in config')
    end

    if class ~= 'default' and fontClasses[class] ~= nil then
        Xist_Config:ApplyNestedOverrides(fontConf, fontClasses[class])
    end

    -- CreateFont *requires* a globally unique name for this font
    -- We won't ever refer to this by its name but we still need to generate a unique name

    local color = fontConf.color[colorCode] or fontConf.color.default

    local fontFullName = "LibXistWOW Runtime Font "..
            fontConf.family .." ".. fontConf.size .." ".. fontConf.flags ..";"..
            color.r ..",".. color.g ..",".. color.b ..":".. color.a ..";"..
            fontConf.justifyH .."-".. fontConf.justifyV

    local isCached = false
    local font
    if _G[fontFullName] then
        -- WOW's CreateFont() stored this in the global scope, use the existing one
        font = _G[fontFullName]
        isCached = true
    else
        font = CreateFont(fontFullName)
        font:SetFont(fontConf.family, fontConf.size, fontConf.flags)
        font:SetTextColor(color.r, color.g, color.b, color.a)
        font:SetJustifyH(fontConf.justifyH)
        font:SetJustifyV(fontConf.justifyV)

        Xist_UI_Widget:Initialize(font, 'font')
    end

    --if class == 'messages' then
    --    DEBUG('GetFontObject', isCached and 'cached' or 'NEW', {class=class, colorCode=colorCode}, fontConf)
    --end

    return font, fontFullName
end


function Xist_UI:MakeWidgetDraggable(widget)
    widget:SetMovable(true)
    widget:EnableMouse(true)
    widget:RegisterForDrag('LeftButton')
    widget:SetScript('OnDragStart', widget.StartMoving)
    widget:SetScript('OnDragStop', widget.StopMovingOrSizing)
end


--- @see https://wowwiki.fandom.com/wiki/UIOBJECT_FontString
function Xist_UI:FontString(parent, className, colorCode)
    parent = parent or Xist_UI.UIParent
    local fontString = parent:CreateFontString(nil)
    Xist_UI_Widget:Initialize(fontString, 'fontString', className)
    fontString:InitializeFontStringWidget(colorCode)
    return fontString
end


function Xist_UI:Frame(parent, className, widgetType, config)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'frame'
    local frame = CreateFrame('Frame', nil, parent)
    Xist_UI_Widget:Initialize(frame, widgetType, className, config)
    return frame
end


function Xist_UI:Panel(parent, className, widgetType, config)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'panel'
    local panel = self:Frame(parent, className, widgetType, config)
    return panel
end


function Xist_UI:MessageFrame(parent, className, widgetType, config)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'messageFrame'
    local panel = self:Panel(parent, className, widgetType, config)
    panel:InitializeMessageFrameWidget()
    return panel
end


function Xist_UI:Slider(parent, className, widgetType, config)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'slider'
    local slider = CreateFrame('Frame', nil, parent)
    Xist_UI_Widget:Initialize(slider, widgetType, className, config)
    slider:InitializeSliderWidget()
    return slider
end


function Xist_UI:ScrollFrame(parent, contentFrame, className, widgetType, config)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'scrollFrame'
    local frame = CreateFrame('ScrollFrame', nil, parent)
    Xist_UI_Widget:Initialize(frame, widgetType, className, config)
    frame:InitializeScrollFrameWidget(contentFrame)
    return frame
end


function Xist_UI:ScrollingMessageFrame(parent, className, widgetType, config)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'scrollingMessageFrame'
    local frame = CreateFrame('ScrollingMessageFrame', nil, parent)
    Xist_UI_Widget:Initialize(frame, widgetType, className, config)
    frame:InitializeScrollingMessageFrameWidget()
    return frame
end


function Xist_UI:Label(parent, className, colorCode, widgetType, config)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'label'
    local label = self:Panel(parent, className, widgetType, config)
    label:InitializeLabelWidget(colorCode)
    return label
end


function Xist_UI:Button(parent, className, widgetType, config)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'button'
    local button = CreateFrame('Button', nil, parent)
    Xist_UI_Widget:Initialize(button, widgetType, className, config)
    button:InitializeButtonWidget()
    return button
end


function Xist_UI:ContextMenu(parent, options, className, widgetType, config)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'contextMenu'
    local menu = self:Panel(parent, className, widgetType, config)
    menu:InitializeContextMenuWidget(options)
    return menu
end


function Xist_UI:Dialog(parent, className, widgetType, config)
    widgetType = widgetType or 'dialog'
    local dialog = self:Panel(parent, className, widgetType, config)
    dialog:InitializeDialogWidget()
    return dialog
end


function Xist_UI:Window(parent, title, className, widgetType, config)
    widgetType = widgetType or 'window'
    local win = self:Dialog(parent, className, widgetType, config)
    win:InitializeWindowWidget(title)
    return win
end
