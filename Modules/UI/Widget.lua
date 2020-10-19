
local ModuleName = "Xist_UI_Widget"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget
Xist_UI_Widget = M

protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local WARNING = protected.WARNING


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
                    obj['_'.. k] = obj[k]
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


--- Initialize a widget.
--- @param obj Frame|Font
--- @param type string
--- @param className string
--- @param config table
function Xist_UI_Widget:Initialize(obj, type, className, config)
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
    obj.widgetClass = className or obj:GetDefaultWidgetClass(type)

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
        obj:InitializeBackdrop()
    end

    if settings.show == false then
        obj:Hide()
    elseif obj.Show then -- show by default, only if the widget supports obj:Show(), which not all do
        obj:Show()
    end
end


function Xist_UI_Widget:GetParentWidget()
    local frame = self
    local parent = self.GetParent and self:GetParent()
    while parent and not parent.widgetType do
        frame = parent
        parent = frame:GetParent()
    end
    return parent -- possibly nil
end


--- Get/Cache this widget's config.
--- @return table
function Xist_UI_Widget:GetWidgetConfig()
    -- if we haven't already computed the class config, do so now
    if not self.widgetConfigCache then
        local namespace = self.widgetType ..'Classes'
        local configNamespace = Xist_Config_Namespace:New(self.config, namespace)
        self.widgetConfigCache = configNamespace:GetClassData(self.widgetClass) or {}
    end
    return self.widgetConfigCache
end


--- Get/Cache this widget's environment.
--- @return table
function Xist_UI_Widget:GetWidgetEnvironment()
    -- if we haven't already computed the class config, do so now
    if not self.widgetEnvironment then
        self.widgetEnvironment = Xist_Config_FrameEnvironment:New(self)
    end
    return self.widgetEnvironment
end


--- Get this widget's backdrop config.
--- @return table
function Xist_UI_Widget:GetBackdropConfig()
    -- if we have not already calculated the widget backdrop config, do so now
    if not self.widgetBackdropConfig then
        self.widgetBackdropConfig = GetBackdropConfig(self)
    end
    return self.widgetBackdropConfig
end


--- Look in the parent environment to determine the default widget class.
--- @param widgetType string
--- @return string default class name for this widgetType
function Xist_UI_Widget:GetDefaultWidgetClass(widgetType)
    widgetType = widgetType or self.widgetType

    local widgetTypeClass = widgetType ..'Class'
    local ENV = self:GetWidgetEnvironment()
    local env = ENV:GetParentEnvironment()
    local result = env[widgetTypeClass] or 'default'

    --DEBUG('GetDefaultWidgetClass', widgetType, '=', result, '// ENV=', env)

    return result
end


--- Get this widget's font object, optionally of a specific color code.
--- @param colorCode string|nil
--- @return Font
function Xist_UI_Widget:GetWidgetFontObject(colorCode)
    colorCode = colorCode or self.widgetColorCode
    local fontClass = self:GetDefaultWidgetClass('font')
    local font = Xist_UI:GetFontObject(self.config, fontClass, colorCode)
    return font
end


function Xist_UI_Widget:InitializeBackdrop()
    -- If there is no backdrop config then there is nothing to do
    local conf = self:GetBackdropConfig()
    if not conf.backdrop then return end

    -- first make sure this frame contains the backdrop mixin
    if not self.SetBackdrop then
        Mixin(self, BackdropTemplateMixin)
    end

    self:SetBackdrop(conf.backdrop)
    --DEBUG('backdrop =', conf.backdrop)

    local c = conf.color
    if c then
        self:SetBackdropColor(c.r, c.g, c.b, c.a)
        --DEBUG('backdrop color =', c)
    end

    if (conf.backdrop.edgeSize or 0) > 0 then
        c = conf.borderColor
        if c then
            self:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
            --DEBUG('backdrop border color =', c)
        end
    end
end


--- Get height of this object.
--- By default WOW uses floating point math which means we get results like 12.000003256.
--- We want the number 12 not the crazy floating point.  We use a documented trick to achieve the integer.
--- @return number
function Xist_UI_Widget:GetHeight()
    return math.floor(self:_GetHeight() + 0.5)
end


--- Get width of this object.
--- By default WOW uses floating point math which means we get results like 12.000003256.
--- We want the number 12 not the crazy floating point.  We use a documented trick to achieve the integer.
--- @return number
function Xist_UI_Widget:GetWidth()
    return math.floor(self:_GetWidth() + 0.5)
end
