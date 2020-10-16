
local ModuleName = "Xist_UI_Common"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Common, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Common
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Common
Xist_UI_Common = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG


local DEFAULT_CLASS_NAME = 'default'


--- Get a key from this object's config hierarchy, with a default if there is no such key.
--- @param path string|table[]
--- @param default any
--- @return any
function Xist_UI_Common:ConfigGet(path, default)
    local value = self.config:GetKey(path)
    if value == nil then
        return default
    end
    return value
end


--- Get a named widget setting, with a default if there is no such setting.
--- @param name string
--- @param default any
--- @return any
function Xist_UI_Common:GetWidgetSetting(name, default)
    if self.widgetSettings and self.widgetSettings[name] ~= nil then
        return self.widgetSettings[name]
    end
    return default
end


--- Get/Cache this widget's config.
--- @return table
function Xist_UI_Common:GetWidgetClassConfig()
    -- if we haven't already computed the class config, do so now
    if not self.widgetClassConf then
        self.widgetClassConf = {} -- default in case there is no config; will be overridden below if possible
        -- if we know what type of widget this is we can compute its config
        if self.widgetType then

            self.widgetClass = self.widgetClass or DEFAULT_CLASS_NAME
            local widgetClassesKey = self.widgetType ..'Classes' -- "buttonClasses", "fontClasses", "panelClasses", etc
            local widgetClassesConf = self:ConfigGet(widgetClassesKey, {})
            -- if there is no specific configuration for this widget:class, then use widget:default
            local widgetClassConf = widgetClassesConf[self.widgetClass] or widgetClassesConf[DEFAULT_CLASS_NAME]

            -- if there is a widget class conf, resolve its full lineage
            if widgetClassConf then
                local i = 1
                while widgetClassConf.parent do
                    -- this widget class conf refers to a parent config key.
                    -- we need to merge the child into the parent

                    -- save a temporary copy of the parent key, then remove it so we don't merge it
                    local parentKey = widgetClassConf.parent
                    widgetClassConf.parent = nil

                    -- merge the child with the parent
                    local parentClassConf = self:ConfigGet(parentKey, {})
                    widgetClassConf = Xist_Config:ApplyNestedOverrides(parentClassConf, widgetClassConf)
                    -- at this point if widgetClassConf.parent exists, it's the parent's parent,
                    -- and we should continue looping to resolve the full lineage.

                    -- prevent infinite loops
                    i = i + 1
                    if i > 10 then
                        error("Widget class config depth too high, possible infinite loop")
                    end
                end
                -- cache this result for future lookups
                self.widgetClassConf = widgetClassConf
            end
        end
        -- only when we first compute it, let's see what it is
        DEBUG('GetWidgetClassConfig', self.widgetType ..':'.. self.widgetClass, '=', self.widgetClassConf)
    end
    return self.widgetClassConf
end


--- Get this widget's backdrop config.
--- @return table
function Xist_UI_Common:GetBackdropConfig()
    -- if we have not already calculated the widget backdrop config, do so now
    if not self.widgetBackdropConfig then
        local widgetClassConf = self:GetWidgetClassConfig()

        -- figure out which backdrop class to apply to this frame
        local backdropClassName = widgetClassConf.backdropClass or DEFAULT_CLASS_NAME

        -- get the backdrop config
        local config = self:ConfigGet({'backdropClasses', backdropClassName}, {})

        -- apply defaults to the config as needed
        local currentClassName = backdropClassName
        local i = 1
        while currentClassName ~= DEFAULT_CLASS_NAME do

            local parentClass = config.parent or DEFAULT_CLASS_NAME
            config.parent = nil -- remove this temporary setting so we can loop without merging it in

            -- change the base config to the parent's config
            local tmp = config
            config = self:ConfigGet({'backdropClasses', parentClass}, {})
            -- apply the child's config as overrides
            Xist_Config:ApplyNestedOverrides(config, tmp)

            currentClassName = parentClass

            i = i + 1
            if i > 10 then
                error("Too much depth in class hierarchy, infinite loop possible")
            end
        end

        self.widgetBackdropConfig = config
    end
    return self.widgetBackdropConfig
end


--- Get a specific class of font from this widget's config, optionally of a specific color code.
--- @param class string|nil 'default' if nil
--- @param colorCode string|nil 'default' if nil
--- @return Font
function Xist_UI_Common:GetFontByClass(class, colorCode)
    return Xist_UI:GetFontObject(self.config, class, colorCode)
end


--- Get this widget's font object, optionally of a specific color code.
--- @param colorCode string|nil
--- @return Font
function Xist_UI_Common:GetWidgetFontObject(colorCode)
    local classConf = self:GetWidgetClassConfig()
    local fontClass = classConf.fontClass or self.widgetClass or 'default'
    local font = self:GetFontByClass(fontClass, colorCode or self.widgetColorCode)
    return font
end


function Xist_UI_Common:InitializeBackdrop()

    -- first make sure this frame contains the backdrop mixin
    if not self.SetBackdrop then
        Mixin(self, BackdropTemplateMixin)
    end

    local conf = self:GetBackdropConfig()

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
function Xist_UI_Common:GetHeight()
    return math.floor(self:_GetHeight() + 0.5)
end


--- Get width of this object.
--- By default WOW uses floating point math which means we get results like 12.000003256.
--- We want the number 12 not the crazy floating point.  We use a documented trick to achieve the integer.
--- @return number
function Xist_UI_Common:GetWidth()
    return math.floor(self:_GetWidth() + 0.5)
end
