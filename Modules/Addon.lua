
local AddonName = ...

local ModuleName = "Xist_Addon"
local ModuleVersion = 1

-- If some other addon installed Xist_Addon, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Addon
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_Addon
Xist_Addon = M

protected.DebugEnabled = true

local VERBOSE_ADDON_LOADED_DEBUG = false

local PlayerName = UnitName("player")

local AddonInstances = {}


--- Get a addon instance by name.
--- This throws an exception if there is no such addon.
--- @param name string
--- @param suppressException boolean default false; if true return nil instead of throwing an exception.
--- @return Xist_Addon|nil
function Xist_Addon.Instance(name, suppressException)
    local addon = AddonInstances[name]
    if not addon and not suppressException then
        -- throw exception
        error("No such addon `".. name .."'")
    end
    return addon -- could be nil
end


--- Create an addon.
--- @param name string
--- @param version Xist_Version|string|number
--- @return Xist_Addon
function Xist_Addon:New(name, version)

    name = name or AddonName
    version = version or 1

    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    AddonInstances[name] = obj -- keep track of this instance by name

    obj.name = name
    obj.version = Xist_Version:New(version)
    obj.slashCommands = {}

    obj.bAnnounceLoad = false
    obj.bDebugEnabled = false

    obj.oSaveDataClass = Xist_SaveData
    obj.tSaveDataScope = _G
    obj.sSaveDataVarName = "XISTDATA__" .. name

    obj.oAddonEventHandler = Xist_EventHandler:NewAddonHandler(name)

    obj.aGlobalEventRegistrations = {
        "ADDON_LOADED",
        "CHAT_MSG_ADDON",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_LOGOUT",
    }

    obj.log = Xist_Log:New(name)

    obj.protected = {
        DEBUG = obj.log:Proxy('LogDebug'),
        DEBUG_CAT = obj.log:Proxy('LogCategorizedDebug'),
        DEBUG_DUMP = obj.log:Proxy('LogDebugDump'),
        ERROR = obj.log:Proxy('LogError'),
        MESSAGE = obj.log:Proxy('LogMessage'),
        WARNING = obj.log:Proxy('LogWarning'),
    }

    obj.DEBUG = protected.NOOP
    obj.DEBUG_CAT = protected.NOOP
    obj.DEBUG_DUMP = protected.NOOP

    -- if module debugging is enabled then enable debugging in addon instances by default
    if protected.DebugEnabled then
        obj:EnableDebug()
    end

    return obj
end


--- Write data to the error log.
--- This public method makes it easy for application code to log errors.
--- @usage addon:ERROR("This is an error with data =", data)
function Xist_Addon:ERROR(...)
    return self.protected.ERROR(...)
end


--- Write data to the log.
--- This public method makes it easy for application code to log messages.
--- @usage addon:MESSAGE("Hello, your data =", data)
function Xist_Addon:MESSAGE(...)
    return self.protected.MESSAGE(...)
end


--- Write data to the warning log.
--- This public method makes it easy for application code to log warnings.
--- @usage addon:WARNING("Warning with data =", data)
function Xist_Addon:WARNING(...)
    return self.protected.WARNING(...)
end


--- Make the addon announce itself after it loads.
function Xist_Addon:AnnounceLoad()
    self.bAnnounceLoad = true
end


--- Enable addon debugging.
--- After calling this, debug messages will be written to the debug log.
--- Note: If you saved references to self.DEBUG or self.DEBUG_DUMP, you MUST
--- reassign them after calling this method.
function Xist_Addon:EnableDebug()
    self.bDebugEnabled = true
    -- activate the debug logs
    self.DEBUG = function (_, ...) self.protected.DEBUG(...) end
    self.DEBUG_CAT = function (_, ...) self.protected.DEBUG_CAT(...) end
    self.DEBUG_DUMP = function (_, ...) self.protected.DEBUG_DUMP(...) end
end


--- Disable addon debugging.
--- After calling this, debug messages and code blocks will be suppressed.
--- Note: If you saved references to self.DEBUG or self.DEBUG_DUMP, you MUST
--- reassign them after calling this method.
function Xist_Addon:DisableDebug()
    self.bDebugEnabled = false
    -- deactivate the debug logs
    self.DEBUG = protected.NOOP
    self.DEBUG_CAT = protected.NOOP
    self.DEBUG_DUMP = protected.NOOP
end


--- Assign a specific class to handle SaveData operations.
--- @param class Xist_SaveData derived class
function Xist_Addon:SetSaveDataClass(class)
    self.oSaveDataClass = class
end


--- Assign a non-global scope for SaveData operations.
--- @param scope table
function Xist_Addon:SetSaveDataScope(scope)
    self.tSaveDataScope = scope
end


--- Set a specific name to use for SaveData.
--- Note this name is in the GLOBAL SCOPE unless you reduce the scope yourself.
--- This name MUST BE UNIQUE of you will have undefined SaveData results.
function Xist_Addon:SetSaveDataName(name)
    self.sSaveDataVarName = name
end


--- Get a reference to the SaveData data.
--- This gives you a reference to the actual data that is saved, not the SaveData wrapper.
--- @return any
function Xist_Addon:GetDataReference()
    return self.CacheData -- possibly nil
end


--- Set the SaveData data.
--- Overwrite any existing SaveData data with the new data.
--- @param data any
function Xist_Addon:SetDataReference(data)
    self.CacheData = data
end


--- Initialize the WOW Frame to listen on all events this addon cares about.
function Xist_Addon:InitializeEvents()

    local obj = self -- create an alias as using the name `self' in a callback can be tricky
    local objSpecificEventCallback = function(eventName, ...)
        return obj[eventName](obj, ...)
    end

    for _, eventName in ipairs(obj.aGlobalEventRegistrations) do
        if obj[eventName] then
            -- register in the global event handler for this event
            Xist_EventHandler:RegisterEvent(eventName, objSpecificEventCallback)
        else
            -- Throw an exception, they asked to be notified of an event but they did not define a callback
            error("Addon `".. obj.name .."' requested registration for event `".. eventName .."' but does not have the appropriate callback method")
        end
    end
end


--- Initialize the addon.
--- Call this after you've made whatever configuration changes you want.
function Xist_Addon:Init()
    self:InitializeEvents()
end


--- @return string This addon's name
function Xist_Addon:GetName()
    return self.name
end


--- @return Xist_Version This addon's version
function Xist_Addon:GetVersion()
    return self.version
end


--- Add support for a slash command.
--- @param commandName string Name of the slashcommand, NOT including the "/" (e.g. "libxist")
function Xist_Addon:AddSlashCommand(commandName)
    local i = 1 + #self.slashCommands
    self.slashCommands[i] = commandName
    local addonIdent = string.upper(self.name)
    local globalName = "SLASH_".. addonIdent .. i
    _G[globalName] = "/".. commandName
end


--- Set the slash command handler callback.
--- @param callback fun(string) Function that takes a string argument with extra command parameters
function Xist_Addon:SetSlashCommandHandler(callback)
    local addonIdent = string.upper(self.name)
    _G.SlashCmdList[addonIdent] = callback
end


--- Register for an addon-specific event.
--- @param eventName string Name of an addon-specific event.
--- @param callback fun
function Xist_Addon:RegisterEvent(eventName, callback)
    self.oAddonEventHandler:RegisterEvent(eventName, callback)
end


--- Get the prefix for addon messages for this addon.
--- By default this uses the addon's name, which if longer than 16 characters will NOT WORK as
--- an addon prefix.
--- @return string|nil
function Xist_Addon:GetAddonMessagePrefix()
    local prefix = self.name
    -- if this prefix is too long then we can't use it!
    if strlen(prefix) > 16 then -- don't remember where I saw this 16 character limit...
        self:WARNING("Addon prefix `".. prefix .."' is too long to use Addon messages")
        return nil
    end
    return prefix
end


--- Install an OnLoad callback.
--- This callback will be called as callback(addon) once the addon has loaded.
--- @param callback fun|nil
function Xist_Addon:OnLoad(callback)
    self:RegisterEvent("OnLoad", callback)
end


--- Handle an ADDON_LOADED event.
--- @param name string name of the addon that loaded (maybe not our addon)
--- @see https://wow.gamepedia.com/AddOn_loading_process
function Xist_Addon:ADDON_LOADED(name)
    if name == self.name then
        -- our own addon has loaded
        self:DEBUG("ADDON_LOADED", name)

        -- read saved data (or construct new default)
        -- never use nil CacheData; other modules need a namespace for OnSaveDataRead/OnSaveDataWrite
        self.SaveData = self.oSaveDataClass:New(self.sSaveDataVarName, self.tSaveDataScope)
        self.CacheData = self.SaveData:Read() or {}

        self:DEBUG("Read Save Data", self.CacheData)
        self.oAddonEventHandler:TriggerEvent("OnSaveDataRead", self.CacheData)

        if self.bAnnounceLoad then
            self.protected.MESSAGE("version", tostring(self.version), "loaded")
        end

        -- execute onload callback if any
        self.oAddonEventHandler:TriggerEvent("OnLoad", self)

    elseif VERBOSE_ADDON_LOADED_DEBUG then
        -- display verbose output regarding addon load order
        self:DEBUG("[OTHER] ADDON_LOADED", name)
    end
end


--- Commit changes to the save data.
function Xist_Addon:WriteSaveData()
    if self.SaveData then
        -- before we write the save data, allow callbacks to make their updates to the cache
        self.oAddonEventHandler:TriggerEvent("OnSaveDataWrite")
        -- now write the save data
        self.SaveData:Write(self.CacheData)
    end
end


--- Handle a PLAYER_LOGOUT event.
function Xist_Addon:PLAYER_LOGOUT()
    self:DEBUG("PLAYER_LOGOUT")
    -- write whatever data is in the cache to the saved data for next load
    self:WriteSaveData()
end


--- Handle a CHAT_MSG_ADDON event.
--- This means an addon has sent us an event notification for a prefix we're registered to watch.
--- @see https://wow.gamepedia.com/CHAT_MSG_ADDON
function Xist_Addon:CHAT_MSG_ADDON(prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID)
    if prefix == self:GetAddonMessagePrefix() then
        -- don't send this player's messages to themselves!
        if target ~= PlayerName then
            self:OnMyAddonMessageReceived(text, channel, sender, target, localID, name)
        end
    else
        self:OnOtherAddonMessageReceived(prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID)
    end
end


--- Player is loading into a part of the world.
--- This gets called on login, on /reload and also when zoning in/out of instances, etc.
--- @param isInitialLogin boolean true if the player has just now logged in
--- @param isReloadingUI boolean true if the user typed /reload, false on zoning in/out of instances etc
--- @see https://wow.gamepedia.com/PLAYER_ENTERING_WORLD
function Xist_Addon:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUI)
    self:DEBUG("PLAYER_ENTERING_WORLD", {isInitialLogin=isInitialLogin, isReloadingUI=isReloadingUI})

    -- Register for my own addon messages
    local prefix = self:GetAddonMessagePrefix()
    if prefix then
        self:DEBUG("Using prefix `".. prefix .."' for Addon messages")
        C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    end
end


-- By default addons ignore messages
Xist_Addon.OnMyAddonMessageReceived = protected.NOOP
Xist_Addon.OnOtherAddonMessageReceived = protected.NOOP


--- Send an addon message.
--- @param message string
function Xist_Addon:SendAddonMessage(message)
    C_ChatInfo.SendAddonMessage(self:GetAddonMessagePrefix(), message, "GUILD", nil)
end
