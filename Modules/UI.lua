
local ModuleName = "Xist_UI"
local ModuleVersion = 1

-- If some other addon installed Xist_UI, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI
Xist_UI = M

protected.DebugEnabled = true

local VERBOSE_INHERITANCE_DEBUG = false and protected.DebugEnabled

local DEBUG = protected.DEBUG
local WARNING = protected.WARNING

-- a full screen frame to be the parent of all Xist_UI elements
-- this way we can easily hide them all in combat, for example
local Xist__UIParent = CreateFrame('Frame', 'Xist__UIParent', UIParent)


--- Inherit parent classes into obj.
--- @param obj table
--- @param inheritClasses table[] list of classes
local function InheritParentClasses(obj, inheritClasses)
    inheritClasses = inheritClasses or {Xist_UI_Widget}

    local wantCopy
    -- copy methods from class to obj
    for _, class in ipairs(inheritClasses) do
        for k, v in pairs(class) do
            -- we do NOT want to copy _meta information
            wantCopy = k ~= '_meta'
            if wantCopy then
                -- if obj already has a method of this name, classify it as the super,
                -- save a reference to it as _methodName
                if obj[k] and type(obj[k]) == 'function' then
                    if VERBOSE_INHERITANCE_DEBUG then
                        DEBUG('InheritParentClasses', obj.widgetType, 'override', k, (obj['_'..k] == nil and '' or 'MULTIPLE_OVERRIDE'))
                    end
                    obj['_'.. k] = obj[k]
                elseif VERBOSE_INHERITANCE_DEBUG then
                    DEBUG('InheritParentClasses', obj.widgetType, 'install', k)
                end
                -- install this class method to obj
                obj[k] = v
            end
        end
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
    local wcData = widget:GetWidgetConfig()
    local configNamespace = Xist_Config_Namespace:New(widget.config, 'backdropClasses')
    return configNamespace:GetClassData(wcData.backdropClass) or {}
end


local function InitializeBackdrop(widget)
    -- If there is no backdrop config then there is nothing to do
    local conf = GetBackdropConfig(widget)
    if not conf.backdrop then return end

    -- first make sure this frame contains the backdrop mixin
    if not widget.SetBackdrop then
        Mixin(widget, BackdropTemplateMixin)
    end

    widget:SetBackdrop(conf.backdrop)
    --DEBUG('backdrop =', conf.backdrop)

    local c = conf.color
    if c then
        widget:SetBackdropColor(c.r, c.g, c.b, c.a)
        --DEBUG('backdrop color =', c)
    end

    if (conf.backdrop.edgeSize or 0) > 0 then
        c = conf.borderColor
        if c then
            widget:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
            --DEBUG('backdrop border color =', c)
        end
    end
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
    local parent = obj.GetParent and obj:GetParent() or nil
    local isParentWidget = parent and parent.widgetType
    local parentConfigObject = isParentWidget and parent.config or Xist_UI_Config

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
        InitializeBackdrop(obj)
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
--- @param config Xist_Config
--- @param class string|nil
--- @param colorCode string|nil
--- @return Font
local function GetOrCreateGlobalFontObject(config, class, colorCode)
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

        Xist_UI:InitializeWidget(font, 'font')
    end

    if not isCached then
        DEBUG('GetOrCreateGlobalFontObject', class ..'+'.. colorCode, fontConf, 'color=', color)
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
    return parent -- possibly nil
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

    local widgetTypeClass = widgetType ..'Class'
    local env

    if isConstructing then
        local parent = Xist_UI:GetParentWidget(widget)
        if parent then
            env = parent:GetWidgetEnvironment()
        end
    else
        env = widget:GetWidgetEnvironment()
    end

    return env and env:GetEnv(widgetTypeClass) or 'default'
end


--- Get this widget's font object, optionally of a specific color code.
--- @param widget Xist_UI_Widget
--- @param fontClass string|nil
--- @param colorCode string|nil
--- @return Font
function Xist_UI:GetFontObject(widget, fontClass, colorCode)
    fontClass = fontClass or Xist_UI:GetWidgetClass(widget, 'font')
    colorCode = colorCode or widget.widgetColorCode or 'default'
    return GetOrCreateGlobalFontObject(widget.config, fontClass, colorCode)
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
    return self:CreateWidget('button', 'Button', parent, className, config)
end


function Xist_UI:ContextMenu(parent, options, className, config)
    return self:CreateWidget('contextMenu', 'Frame', parent, className, config, {options})
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
    return self:CreateWidget('window', 'Frame', parent, className, config, {title})
end


Xist_UI:InitializeWidget(Xist__UIParent, 'frame', 'default')
Xist__UIParent:SetAllPoints() -- occupy the entire screen
Xist__UIParent:Show() -- show UI by default
