
local ModuleName = "Xist_UI_Widget"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget
Xist_UI_Widget = M


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
