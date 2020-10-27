
local ModuleName = "Xist_Config_UI"
local ModuleVersion = 1

-- If some other addon installed Xist_Config_UI, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Config_UI
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion, Xist_Config:New())

--- @class Xist_Config_UI
Xist_Config_UI = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG


function Xist_Config_UI:New(config, parent)
    local obj = Xist_Config:New(config, parent)
    setmetatable(obj, self)
    self.__index = self

    obj.registeredWidgets = {}

    return obj
end


function Xist_Config_UI:GetWidgetInheritance(widgetType)
    local inheritance
    if self.registeredWidgets[widgetType] then
        inheritance = self.registeredWidgets[widgetType].inheritance
    end
    -- supply a suitable default for unregistered widgets or inappropriately registered widgets
    if not inheritance then
        inheritance = {}
    end
    return inheritance
end


function Xist_Config_UI:GetWidgetInitializeMethod(widgetType)
    local reg = self.registeredWidgets[widgetType]
    return reg and reg.initFunc -- possibly nil
end


function Xist_Config_UI:SetWidgetInheritance(widgetType, inheritance)
    if not inheritance then
        inheritance = {}
    elseif type(inheritance) == 'table' then
        for _, className in ipairs(inheritance) do
            if type(className) ~= 'string' then
                error('Invalid type '.. type(className) ..'; expected string class name')
            end
        end
    elseif type(inheritance) == 'string' then
        inheritance = {inheritance}
    else
        error('Invalid type '.. type(inheritance) ..'; expected string or table[] for class inheritance')
    end
    self.registeredWidgets[widgetType].inheritance = inheritance
end


function Xist_Config_UI:SetWidgetSettingsData(widgetType, data)
    local key = {'widgetSettings', widgetType}
    self:SetKey(key, data)
end


function Xist_Config_UI:SetWidgetClassData(widgetType, data)
    local key = widgetType ..'Classes'
    self:SetKey(key, data)
end


function Xist_Config_UI:RegisterWidget(widgetType, inheritance, settings, classConfigs, initFunc)
    DEBUG('RegisterWidget', widgetType)
    self.registeredWidgets[widgetType] = {
        initFunc = initFunc, -- possibly nil
    }
    self:SetWidgetInheritance(widgetType, inheritance)
    self:SetWidgetSettingsData(widgetType, settings)
    self:SetWidgetClassData(widgetType, classConfigs)
end
