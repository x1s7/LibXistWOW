--- @module Xist_Module
local AddonName = ...

local ModuleVersion = 1

Xist_Module = Xist_Module or {}
-- If some other addon installed Xist_Module, don't do it again
if Xist_Module.version and Xist_Module.version >= ModuleVersion then
    return
end

-- Initialize Xist_Module

Xist_Module.modules = {}
Xist_Module.version = ModuleVersion

--- Prefix of global saved data name.
local SAVED_DATA_PREFIX = "Xist_Save__"

--- Whether or not debugging is enabled in modules by default.
local DEBUG_ENABLED_DEFAULT = false


--- "NO OPeration" function; does nothing.
--- Useful for disabling callbacks by default, for example.
local NOOP = function() end


--- Add/Update a Xist module.
--- @param name string fully qualified path to module like "Foo_Bar_Baz"
--- @param version number
--- @param lib table|nil key=value pairs to add to the module
--- @return table, table, table publicModule, protectedModule, privateModule
function Xist_Module.AddModule(name, version, lib)
    version = version or 1
    lib = lib or {}

    local module = Xist_Module.modules[name]
    if not module then
        -- there is no existing module, use lib as the module
        module = lib
    elseif module._meta.version >= version then
        -- there is an existing module with greater or equal version to this,
        -- so keep the one we already have and don't add a new one
        return nil
    else
        -- module._meta.version is less than version, so this is a new/updated
        -- version of the module.  we want to replace the lower level module
        -- with the higher level one
        module = lib
    end

    local moduleLogIdent = name
    local addonSavedDataVar = SAVED_DATA_PREFIX .. AddonName

    -- Overwrite previous stuff in module._meta.private from parent classes
    module._meta = module._meta or {}
    module._meta.name = name
    module._meta.version = version

    local private = {}
    module._meta.private = private

    private.DEBUG = Xist_Log.Factory.DEBUG(moduleLogIdent)
    private.DEBUG_DUMP = Xist_Log.Factory.DEBUG_DUMP(moduleLogIdent)

    local protected = {}
    module._meta.protected = protected

    protected.DebugEnabled = DEBUG_ENABLED_DEFAULT

    protected.MESSAGE = Xist_Log.Factory.MESSAGE(moduleLogIdent)
    protected.WARNING = Xist_Log.Factory.WARNING(moduleLogIdent)
    protected.ERROR = Xist_Log.Factory.ERROR(moduleLogIdent)

    protected.DEBUG = function(...)
        if protected.DebugEnabled == true then
            return private.DEBUG(...)
        end
    end

    protected.DEBUG_DUMP = function(...)
        if protected.DebugEnabled == true then
            return private.DEBUG_DUMP(...)
        end
    end

    --- @return table module-specific saved data
    protected.ReadSavedData = function()
        return _G[addonSavedDataVar] and Xist_Util.DeepCopy(_G[addonSavedDataVar][name]) or nil -- possibly nil
    end

    --- @param data table module-specific saved data
    protected.WriteSavedData = function(data)
        if _G[addonSavedDataVar] == nil then
            _G[addonSavedDataVar] = {}
        end
        _G[addonSavedDataVar][name] = Xist_Util.DeepCopy(data)
    end

    protected.NOOP = NOOP

    return module, module._meta.protected, module._meta.private
end


--- Get a Xist module.
--- @return table, table, table publicModule, privateModule, protectedModule
function Xist_Module.GetModule(name)
    local module = Xist_Module.modules[name]
    if module == nil then
        -- throw an exception
        error("Request for unloaded module: " .. name)
    end
    return module, module._meta.protected, module._meta.private
end


--- Determine if a module needs to be upgraded (or installed in the first place).
--- @param moduleName string
--- @param moduleVersion number
--- @return boolean false if this module exists with the same or greater version, else true
function Xist_Module.NeedsUpgrade(moduleName, moduleVersion)
    local module = Xist_Module.modules[moduleName]
    if module and moduleVersion <= module._meta.version then
        return false
    end
    return true
end
