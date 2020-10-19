
local ModuleName = "Xist_Config_Namespace"
local ModuleVersion = 1

-- If some other addon installed Xist_Config_Namespace, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Config_Namespace
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_Config_Namespace
Xist_Config_Namespace = M

protected.DebugEnabled = true

local DEBUG = protected.DEBUG


--- @param parent Xist_Config
--- @param namespace string|table[]|nil
--- @return Xist_Config_Namespace
function Xist_Config_Namespace:New(parent, namespace)
    local obj = {
        defaultClassName = 'default',
        maxDepth = 10,
        namespace = namespace, -- possibly nil
        parent = parent,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end


--- @param namespace string|table[] 'name' or {'path','to','name'}
function Xist_Config_Namespace:SetNamespace(namespace)
    self.namespace = namespace
end


--- @param maxDepth number
function Xist_Config_Namespace:SetMaxDepth(maxDepth)
    self.maxDepth = maxDepth
end


function Xist_Config_Namespace:ExpireCache()
    self.myNamespaceDataCache = nil
end


--- Read the config namespace data; instead of nil, initialize empty namespace {}.
function Xist_Config_Namespace:ReadCacheIfNeeded()
    if not self.myNamespaceDataCache then
        self.myNamespaceDataCache = self.parent:GetKey(self.namespace) or {}
    end
end


--- @param name string
function Xist_Config_Namespace:IsValidClassName(name)
    self:ReadCacheIfNeeded()
    return self.myNamespaceDataCache[name] ~= nil
end


--- @return table[] list of this widget's possible class names
function Xist_Config_Namespace:GetClassNames()
    self:ReadCacheIfNeeded()

    local result = {}
    for n, _ in pairs(self.myNamespaceDataCache) do
        result[1+#result] = n
    end
    return result
end


--- Get the entire config under this namespace.
--- @return table
function Xist_Config_Namespace:GetConfigData()
    self:ReadCacheIfNeeded()
    return Xist_Util.Copy(self.myNamespaceDataCache)
end


--- @param className string
--- @param nesting nil|table[] (internal use only)
--- @return table
function Xist_Config_Namespace:GetClassData(className, nesting)
    self:ReadCacheIfNeeded()

    className = className or self.defaultClassName
    nesting = nesting or {}

    nesting[1+#nesting] = className

    if #nesting > self.maxDepth then
        error('Possible recursion stopped at level '.. #nesting ..': '.. Xist_Util.Join(nesting, '/'))
    end

    local data = self.myNamespaceDataCache[className]
    if data == nil then
        -- this className does not exist in the config.
        -- if className is not the default class, then look for the default class config.
        if className ~= self.defaultClassName then
            data = self:GetClassData(self.defaultClassName, nesting)
            className = self.defaultClassName
        end
    end

    -- if this isn't the default class, then merge in the default class
    if data and className ~= self.defaultClassName then
        local parentClassName = data.parent or self.defaultClassName
        local childData = data
        childData.parent = nil -- remove this so it doesn't get merged
        data = self:GetClassData(parentClassName, nesting)
        if data then
            -- we did get a default config
            Xist_Config:ApplyNestedOverrides(data, childData)
        else
            -- there is no default config, just use the child config
            data = childData
        end
    end

    return data -- possibly nil
end
