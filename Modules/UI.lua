
local ModuleName = "Xist_UI"
local ModuleVersion = 1

-- If some other addon installed Xist_UI, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI
Xist_UI = M

--protected.DebugEnabled = true

local VERBOSE_INHERITANCE_DEBUG = protected.DebugEnabled and false
local VERBOSE_CLASS_DEBUG = protected.DebugEnabled and false
local VERBOSE_FONT_CREATION = protected.DebugEnabled and true
local THROW = false

local DEBUG = protected.DEBUG
local DEBUG_CAT = protected.DEBUG_CAT
local WARNING = protected.WARNING

local DEFAULT_FONT = {
    family = [[Fonts\FRIZQT__.ttf]],
    size = 12,
    flags = '', -- OUTLINE,THICKOUTLINE,MONOCHROME
    justifyH = 'CENTER',
    justifyV = 'MIDDLE',
    color = {
        default = { r=0, g=0, b=0, a=1 },
        disabled = { r=0.6, g=0.6, b=0.6, a=1 },
        highlight = { r=1, g=1, b=0, a=1 },
    },
}

-- a full screen frame to be the parent of all Xist_UI elements
-- this way we can easily hide them all in combat, for example
local Xist__UIParent = CreateFrame('Frame', 'Xist__UIParent', UIParent)


local function InheritParentClass(obj, parentClassName)
    local class = _G[parentClassName]
    if class == nil then
        error('No such parent class: `'.. parentClassName .."'")
    end
    local wantCopy
    for k, v in pairs(class) do
        -- we do NOT want to copy _meta information
        wantCopy = k ~= '_meta'
        if wantCopy then
            -- if obj already has a method of this name, classify it as the super,
            -- save a reference to it as _methodName
            if obj[k] and type(obj[k]) == 'function' then
                if VERBOSE_INHERITANCE_DEBUG then
                    DEBUG('InheritParentClasses', obj.widgetType, 'override', parentClassName ..'.'.. k, (obj['_'..k] == nil and '' or 'MULTIPLE_OVERRIDE'))
                end
                obj['_'.. k] = obj[k]
            elseif VERBOSE_INHERITANCE_DEBUG then
                DEBUG('InheritParentClasses', obj.widgetType, 'install', parentClassName ..'.'.. k)
            end
            -- install this class method to obj
            obj[k] = v
        end
    end
end


--- Inherit parent classes into obj.
--- @param obj table
--- @param inheritClasses table[] list of classes
local function InheritParentClasses(obj, inheritClasses)
    inheritClasses = inheritClasses or {}

    -- ALL widgets MUST inherit Xist_UI_Widget
    InheritParentClass(obj, 'Xist_UI_Widget')

    -- copy methods from class to obj
    for _, className in ipairs(inheritClasses) do
        InheritParentClass(obj, className)
    end
end


--- @param widget Xist_UI_Widget
--- @return table
local function GetWidgetSettings(widget)
    local cc = Xist_Config_Namespace:New(widget.config, 'widgetSettings')
    local settings = cc:GetClassData(widget.widgetType)
    if not settings then
        error('No widget settings defined for widgetType=`'.. widget.widgetType .."'")
    end
    return settings
end


--- @param widget Xist_UI_Widget
--- @return table
local function GetBackdropConfig(widget)
    local env = widget:GetWidgetEnvironment()
    local class = env:GetEnv('backdropClass')
    local conf = {}
    if class then
        local configNamespace = Xist_Config_Namespace:New(widget.config, 'backdropClasses')
        conf = configNamespace:GetClassData(class) or {}
        conf.backdropClass = class
    end
    return conf
end


function Xist_UI:InitializeBackdrop(widget)
    -- Initialize the border width as zero, we'll override it below if this widget has a backdrop
    -- that has a border width.
    widget.widgetBorderWidth = 0

    local debugInfo = {
        widgetClass = widget.widgetClass,
    }
    local backdropColor
    local borderColor

    -- first make sure this frame contains the backdrop mixin if possible
    if not widget.SetBackdrop then
        if BackdropTemplateMixin then
            Mixin(widget, BackdropTemplateMixin)
            debugInfo.mixin = true
        else
            -- this happens in Classic for fontString and texture widgets
            --DEBUG_CAT('InitializeBackdrop '.. widget.widgetType, '-- NO SetBackdrop ON THIS WIDGET AND NO BackdropTemplateMixin IN THIS WOW CLIENT')
            return
        end
    end

    -- If there is no backdrop config then there is nothing to do
    local conf = GetBackdropConfig(widget)

    if conf.backdrop then
        -- backdrops have been enabled for this widget

        widget:SetBackdrop(conf.backdrop)

        local c = conf.backdropColor
        if c then
            widget:SetBackdropColor(c.r, c.g, c.b, c.a)
            backdropColor = c
        end

        -- Remember the border width size for this widget for future positioning calculations
        widget.widgetBorderWidth = conf.backdrop.edgeSize or 0

        if widget.widgetBorderWidth > 0 then
            c = conf.borderColor
            if c then
                widget:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
                borderColor = c
            end
        end
    else
        debugInfo.empty = true
    end

    DEBUG_CAT('InitializeBackdrop '.. widget.widgetType, debugInfo, 'backdropColor=', backdropColor, 'borderColor=', borderColor)
end


--- Get the border width of a widget.
--- This won't work unless you call it AFTER InitializeWidget has called InitializeBackdrop.
--- This uses a cached value generated by InitializeBackdrop to fetch the border width.
--- @param widget Xist_UI_Widget
--- @return number
function Xist_UI:GetWidgetBorderWidth(widget)
    return widget.widgetBorderWidth or 0
end


--- Initialize a widget.
--- @param obj Frame|Font|Texture
--- @param type string
--- @param className string
--- @param config table
--- @param initArgs table[]
function Xist_UI:InitializeWidget(obj, type, className, config, initArgs)
    -- first mark the type of widget this is
    obj.widgetType = type

    -- Inherit parent classes, if any
    local inheritance = Xist_UI_Config:GetWidgetInheritance(type)
    if inheritance then
        InheritParentClasses(obj, inheritance)
    end

    -- find out if there is a parent frame attached to this object
    local parentWidget = Xist_UI:GetParentWidget(obj)
    local parentConfigObject = parentWidget and parentWidget.config or Xist_UI_Config

    -- if config is nil, then this will simply create a pseudo config that inherits
    -- all the attributes of the parent's config.
    -- if config is non-nil, then it is a set of overrides to the parent config.
    obj.config = Xist_Config:New(config, parentConfigObject)

    -- apply widget settings -- AFTER setting obj.widgetType AND obj.config
    local settings = GetWidgetSettings(obj)
    obj.widgetSettings = settings

    -- if there is not an overriding className explicit to this widget,
    -- look in the parent widget to determine what class this widget type
    -- should default to.
    obj.widgetClass = className or Xist_UI:GetWidgetClass(obj, type, true)

    -- Save the settings for later reference
    obj.widgetSettings = settings

    -- Initialize the backdrop, if any
    Xist_UI:InitializeBackdrop(obj)

    -- TODO these things should not be widget settings, they should be widget CLASS settings

    if settings.width ~= nil then
        obj:SetWidth(settings.width)
    end

    if settings.height ~= nil then
        obj:SetHeight(settings.height)
    end

    if settings.clampedToScreen == true then
        obj:SetClampedToScreen(true)
    end

    if settings.strata ~= nil then
        obj:SetFrameStrata(settings.strata)
    end

    if settings.anchors and #settings.anchors then
        for _, anchor in ipairs(settings.anchors) do
            obj:SetPoint(unpack(anchor))
        end
    end

    if settings.backdrop then
        Xist_UI:InitializeBackdrop(obj)
    end

    if settings.show == false then
        obj:Hide()
    elseif obj.Show then -- show by default, only if the widget supports obj:Show(), which not all do
        obj:Show()
    end

    local init = Xist_UI_Config:GetWidgetInitializeMethod(type)
    if init then
        init(obj, initArgs and unpack(initArgs))
    end

    return obj
end


--- Get or Create a Font object with settings defined in the config.
--- Created objects are cached globally for reuse.
--- @param widget
--- @param class string|nil
--- @param colorCode string|nil
--- @return Font
local function GetOrCreateGlobalFontObject(widget, class, colorCode)
    class = class or Xist_UI:GetWidgetClass(widget, 'font') or 'default'
    colorCode = colorCode or widget.widgetColorCode or 'default'

    local configNamespace = Xist_Config_Namespace:New(widget.config, 'fontClasses')
    local fontConf = configNamespace:GetClassData(class) or {}

    local color = fontConf.color and (fontConf.color[colorCode] or fontConf.color.default) or DEFAULT_FONT.color.default

    -- CreateFont *requires* a globally unique name for this font
    -- We won't ever refer to this by its name but we still need to generate a unique name

    local fontFullName = "LibXistWOW Runtime Font "..
            class ..":".. colorCode .."/"..
            fontConf.family .."/".. fontConf.size .."/".. fontConf.flags .."/"..
            color.r ..",".. color.g ..",".. color.b ..",".. color.a .."/"..
            fontConf.justifyH .."/".. fontConf.justifyV

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

        Xist_UI:InitializeWidget(font, 'font', class)
    end

    if VERBOSE_FONT_CREATION then
        if not isCached then
            DEBUG_CAT('GetOrCreateGlobalFontObject '.. class ..'+'.. colorCode, fontConf, 'color=', color, {key=fontFullName})
        end
    end

    return font, fontFullName
end


--- @return Xist_UI_Widget|nil
function Xist_UI:GetParentWidget(widget)
    local frame = widget
    local parent = widget.GetParent and widget:GetParent()
    while parent and not parent.widgetType do
        frame = parent
        parent = frame:GetParent()
    end
    -- only return the parent frame if it is a widget
    if parent and parent.widgetType then
        return parent
    end
    return nil
end


--- Look in the environment to determine the class of a given widget type.
--- If called during widget construction/initialization, we will NOT generate the widget
--- environment, and will instead defer to the parent widget.  This is because some of the
--- environment is based on the class of widget, which must be known before querying the
--- environment of the widget itself.
--- @param widget Xist_UI_Widget
--- @param widgetType string
--- @param isConstructing boolean if true we will only look in the parent environment
--- @return string default class name for this widgetType
function Xist_UI:GetWidgetClass(widget, widgetType, isConstructing)
    widgetType = widgetType or widget.widgetType

    local configKey = widgetType ..'Class'
    local env

    if isConstructing then
        local parent = Xist_UI:GetParentWidget(widget)
        if parent then
            env = parent:GetWidgetEnvironment()
        end
    else
        env = widget:GetWidgetEnvironment()
    end

    local class = env and env:GetEnv(configKey) or 'default'

    if VERBOSE_CLASS_DEBUG then
        DEBUG_CAT('GetWidgetClass '.. widgetType,
                {isConstructing=isConstructing, class=class},
                'env=', (env and env:GetAll()))

        if env == nil and isConstructing and class == 'default' then
            if THROW then
                error('HEREIAMJH')
            end
        end
    end

    return class
end


--- Get this widget's font object, optionally of a specific color code.
--- @param widget Xist_UI_Widget
--- @param fontClass string|nil
--- @param colorCode string|nil
--- @return Font
function Xist_UI:GetFontObject(widget, fontClass, colorCode)
    return GetOrCreateGlobalFontObject(widget, fontClass, colorCode)
end


--- @param widget Xist_UI_Widget
function Xist_UI:MakeWidgetDraggable(widget)
    widget:SetMovable(true)
    widget:EnableMouse(true)
    widget:RegisterForDrag('LeftButton')
    widget:SetScript('OnDragStart', widget.StartMoving)
    widget:SetScript('OnDragStop', widget.StopMovingOrSizing)
end


function Xist_UI:CreateWidget(widgetType, frameType, parent, className, config, initArgs)
    widgetType = widgetType or 'frame'
    frameType = frameType or 'Frame'
    parent = parent or Xist__UIParent
    local widget = CreateFrame(frameType, nil, parent)
    return Xist_UI:InitializeWidget(widget, widgetType, className, config, initArgs)
end


--- @see https://wowwiki.fandom.com/wiki/UIOBJECT_FontString
function Xist_UI:FontString(parent, className, colorCode)
    parent = parent or Xist__UIParent
    local fontString = parent:CreateFontString()
    return Xist_UI:InitializeWidget(fontString, 'fontString', className, nil, {colorCode})
end


function Xist_UI:Texture(parent, className)
    parent = parent or Xist__UIParent
    local tex = parent:CreateTexture()
    return Xist_UI:InitializeWidget(tex, 'texture', className)
end


function Xist_UI:Button(parent, className, config)
    --VERBOSE_INHERITANCE_DEBUG = protected.DebugEnabled
    local widget = self:CreateWidget('button', 'Frame', parent, className, config)
    --VERBOSE_INHERITANCE_DEBUG = false
    return widget
end


function Xist_UI:ContextMenu(parent, options, className, config)
    DEBUG_CAT('ContextMenu >>>>>>>>>>')
    local widget = self:CreateWidget('contextMenu', 'Frame', parent, className, config, {options})
    DEBUG_CAT('ContextMenu <<<<<<<<<<')
    return widget
end


function Xist_UI:Dialog(parent, className, config)
    return self:CreateWidget('dialog', 'Frame', parent, className, config)
end


function Xist_UI:Frame(parent, className, widgetType, config)
    return self:CreateWidget(widgetType, 'Frame', parent, className, config)
end


function Xist_UI:Label(parent, className, colorCode, config)
    return self:CreateWidget('label', 'Frame', parent, className, config, {colorCode})
end


function Xist_UI:MessageFrame(parent, className, config)
    return self:CreateWidget('messageFrame', 'Frame', parent, className, config)
end


function Xist_UI:Panel(parent, className, config)
    return self:CreateWidget('panel', 'Frame', parent, className, config)
end


function Xist_UI:ScrollFrame(parent, contentFrame, className, config)
    return self:CreateWidget('scrollFrame', 'ScrollFrame', parent, className, config, {contentFrame})
end


function Xist_UI:ScrollingMessageFrame(parent, className, config)
    return self:CreateWidget('scrollingMessageFrame', 'ScrollingMessageFrame', parent, className, config)
end


function Xist_UI:Slider(parent, className, config)
    return self:CreateWidget('slider', 'Frame', parent, className, config)
end


function Xist_UI:Table(parent, options, className, config)
    return self:CreateWidget('table', 'Frame', parent, className, config, {options})
end


function Xist_UI:Window(parent, title, className, config)
    --VERBOSE_CLASS_DEBUG = protected.DebugEnabled -- on if debugging is on
    local widget = self:CreateWidget('window', 'Frame', parent, className, config, {title})
    --VERBOSE_CLASS_DEBUG = false
    return widget
end


Xist_UI:InitializeWidget(Xist__UIParent, 'frame', 'default')
Xist__UIParent:SetAllPoints() -- occupy the entire screen
Xist__UIParent:Show() -- show UI by default
