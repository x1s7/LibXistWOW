--- @module Xist_Module

local ModuleVersion = 1

-- If some other addon installed Xist_Module, don't do it again unless an upgrade is needed
if Xist_Module and Xist_Module.version and Xist_Module.version >= ModuleVersion then return end

-- Initialize Xist_Module

Xist_Module = {
    version = ModuleVersion,
}

local InstalledModules = {}

--- Whether or not debugging is enabled in modules by default.
local DEBUG_ENABLED_DEFAULT = false

--- "NO OPeration" function; does nothing.
--- Useful for disabling callbacks by default, for example.
local NOOP = function() end

local DEBUG = print


local function GeneratePrivateNamespace(module)
    local private = {}

    private.Log = Xist_Log:New(module._meta.name)

    private.DEBUG = private.Log:Proxy('LogDebug')
    private.DEBUG_DUMP = private.Log:Proxy('LogDebugDump')

    return private
end


local function GenerateProtectedNamespace(module)
    local private = module._meta.private
    local protected = {}

    protected.DebugEnabled = DEBUG_ENABLED_DEFAULT

    protected.ERROR = private.Log:Proxy('LogError')
    protected.MESSAGE = private.Log:Proxy('LogMessage')
    protected.WARNING = private.Log:Proxy('LogWarning')

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

    protected.NOOP = NOOP

    return protected
end


--- Install a Xist_Module.
--- @param name string fully qualified path to module like "Foo_Bar_Baz"
--- @param version number
--- @param module table|nil key=value pairs to add to the module
--- @return table, table, table publicModule, protectedModule, privateModule
function Xist_Module.Install(name, version, module)

    name = name or "__noname__"
    version = version or 1
    module = module or {}

    module._meta = {
        name = name,
        version = version,
    }

    -- AFTER _meta is established, generate private namespace
    module._meta.private = GeneratePrivateNamespace(module)

    -- AFTER the private namespace is generated, THEN the protected can be generated
    module._meta.protected = GenerateProtectedNamespace(module)

    --DEBUG("Xist_Module.Register(`".. name .."', ".. version ..")")

    InstalledModules[name] = module

    return module, module._meta.protected, module._meta.private
end


--- Get a Xist module.
--- @return table, table, table publicModule, privateModule, protectedModule
function Xist_Module.GetModule(name)
    local module = InstalledModules[name]
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
    local result = true
    local module = InstalledModules[moduleName]
    if module and moduleVersion <= module._meta.version then
        result = false
    end
    --DEBUG("Xist_Module.NeedsUpgrade(`".. moduleName .."', ".. moduleVersion ..") == ".. (result and "true" or "false"))
    return result
end
