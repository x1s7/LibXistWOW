
local ModuleName = "Xist_Config"
local ModuleVersion = 1

-- If some other addon installed Xist_Config, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Config
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_Config
Xist_Config = M


Xist_Config.NIL = {'SPECIFIC_TABLE_ID__MEANS__DELETE_THIS_CONFIG_KEY'}


function Xist_Config:New(config, parent)
    if config then
        -- if config is a Xist_Config then resolve its data immediately
        if type(config.GetConfig) == 'function' then
            config = config:GetConfig()
        else -- otherwise make a deep copy so we can modify the config in place
            config = Xist_Util.DeepCopy(config)
        end
    end
    local obj = {
        version = 1,
        parent = parent, -- possibly nil
        config = config, -- possibly nil
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end


--- Apply configuration overrides.
--- @param config table The original config table. Will be modified in-place if overwrite=false
--- @param overrides table A table containing override key=value pairs.
--- @return table
function Xist_Config:ApplyNestedOverrides(config, overrides)
    -- if there are no overrides then do nothing
    if overrides == nil then
        return config
    end
    -- iterate the overrides and apply them to the config
    for k, v in pairs(overrides) do
        if type(v) == 'table' then
            -- override value is a table
            if v[1] == Xist_Config.NIL[1] and #v == 1 then
                -- override value is a specific table that means DELETE this from the config
                config[k] = nil
            elseif config[k] == nil then
                -- override value is a non-delete table and this key does not exist in the config
                config[k] = v
            elseif type(config[k]) == 'table' then
                -- override value is a non-delete table, and config[k] is already a table.
                -- override nested table values.
                self:ApplyNestedOverrides(config[k], v)
            end
        else
            -- value is not a table, so assign it outright
            config[k] = v -- full config replace
        end
    end
    return config
end


function Xist_Config:Override(overrides)
    if self.config == nil then
        self.config = {}
    end
    self:ApplyNestedOverrides(self.config, overrides)
    self.version = self.version + 1
end


function Xist_Config:SetKey(path, value)
    if self.config == nil then
        self.config = {}
    end
    if type(path) ~= 'table' then
        path = {path}
    end
    local ref = self.config
    local k
    for i = 1, #path - 1 do
        k = path[i]
        -- if this key does not exist or is not a table, initialize an empty table
        if ref[k] == nil or type(ref[k]) ~= 'table' then
            ref[k] = {}
        end
        -- traverse to the next level of depth
        ref = ref[k]
    end
    -- now we're at the last point in the path, assign the value
    k = path[#path]
    ref[k] = value
    -- mark as dirty now we've changed the config
    self.version = self.version + 1
end


function Xist_Config:SetKeyInLowestNonEmptyNamespace(path, value)
    -- traverse up the lineage until we find a config that is not empty
    local obj = self
    while obj.config == nil and obj.parent do
        obj = obj.parent
    end
    -- here is where we write the config change
    obj:SetKey(path, value)
end


function Xist_Config:GetLineage()
    local lineage = {}
    local parent = self.parent
    while parent do
        table.insert(lineage, parent)
        parent = parent.parent
    end
    -- now reverse the lineage to start with the oldest ancestor rather than the youngest
    local result = {}
    for i = #lineage, 1, -1 do
        table.insert(result, lineage[i])
    end
    -- finally, add self as the last descendent
    table.insert(result, self)
    return result
end


function Xist_Config:IsDirty()
    if not self.parent then
        return false
    end
    -- this config does have a lineage we need to check
    if not self.versionResolution then
        -- we've never resolved the config, it's dirty
        return true
    elseif self.version ~= self.versionResolution[#self.versionResolution] then
        -- the local object has been modified since last mergedConfig
        return true
    end
    -- the current config is clean; check its lineage to see if any of them have changed
    local parent = self.parent
    for i = #self.versionResolution - 1, 1, -1 do
        if not parent or parent.version ~= self.versionResolution[i] then
            return true
        end
        parent = parent.parent
    end
    return false
end


function Xist_Config:Resolve()
    if self.parent then
        self.versionResolution = {}
        local result
        local lineage = self:GetLineage()
        for i, config in ipairs(lineage) do
            table.insert(self.versionResolution, config.version)
            if i == 1 then
                -- this is the oldest ancestor, this is the base config
                result = Xist_Util.Copy(config.config)
            else
                -- this is 1 generation younger, apply its overrides
                self:ApplyNestedOverrides(result, config.config)
            end
        end
        self.mergedConfig = result
    end
end


function Xist_Config:CleanIfDirty()
    if self.parent then
        -- we have a parent, we need to re-resolve the config if any ancestor is dirty
        if self:IsDirty() then
            self:Resolve()
        end
    else
        -- we have no parent, simply return the config itself
        self.mergedConfig = self.config
    end
end


function Xist_Config:GetConfig()
    self:CleanIfDirty()
    return Xist_Util.DeepCopy(self.mergedConfig)
end


function Xist_Config:GetKey(path)
    if type(path) ~= 'table' then
        path = {path}
    end
    self:CleanIfDirty()
    local result = self.mergedConfig
    for _, k in ipairs(path) do
        -- at this point in the path we no longer have a table, but there is still more path to traverse
        if type(result) ~= 'table' then
            return nil
        end
        -- there is more table to traverse
        if result[k] == nil then
            return nil
        end
        result = result[k]
    end
    return Xist_Util.DeepCopy(result)
end
