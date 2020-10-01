
local AddonName = ...

local ModuleName = "Xist_Addon"
local ModuleVersion = 1

-- If some other addon installed Xist_Addon, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Addon
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_Addon
Xist_Addon = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local DEBUG_DUMP = protected.DEBUG_DUMP
local MESSAGE = protected.MESSAGE
local WARNING = protected.WARNING

local PlayerName = UnitName("player")

local AddonInstances = {}


function Xist_Addon.Instance(name)
    local addon = AddonInstances[name]
    if not addon then
        -- throw exception
        error("No such addon `".. name .."'")
    end
    return addon
end


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

    obj.aFrameEventRegistrations = {
        "ADDON_LOADED",
        "CHAT_MSG_ADDON",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_LOGOUT",
    }

    obj.log = Xist_Log:New(name)

    obj.private = {
        DEBUG = obj.log:Proxy('LogDebug'),
        DEBUG_DUMP = obj.log:Proxy('LogDebugDump'),
        ERROR = obj.log:Proxy('LogError'),
        MESSAGE = obj.log:Proxy('LogMessage'),
        WARNING = obj.log:Proxy('LogWarning'),
    }

    obj.protected = {
        DEBUG = protected.NOOP,
        DEBUG_DUMP = protected.NOOP,
        ERROR = obj.private.ERROR,
        MESSAGE = obj.private.MESSAGE,
        WARNING = obj.private.WARNING,
    }

    return obj
end


function Xist_Addon:AnnounceLoad()
    self.bAnnounceLoad = true
end


function Xist_Addon:EnableDebug()
    self.bDebugEnabled = true
    -- activate the debug logs
    self.protected.DEBUG = self.private.DEBUG
    self.protected.DEBUG_DUMP = self.private.DEBUG_DUMP
end


function Xist_Addon:DisableDebug()
    self.bDebugEnabled = false
    -- activate the debug logs
    self.protected.DEBUG = protected.NOOP
    self.protected.DEBUG_DUMP = protected.NOOP
end


function Xist_Addon:InitializeEvents()

    local obj = self -- create an alias as using the name `self' in a callback can be tricky
    local objSpecificEventCallback = function(eventName, ...)
        return obj[eventName](obj, ...)
    end

    for _, eventName in ipairs(obj.aFrameEventRegistrations) do
        if obj[eventName] then
            Xist_EventHandler:RegisterEvent(eventName, objSpecificEventCallback)
        else
            -- Throw an exception, they asked to be notified of an event but they did not define a callback
            error("Addon `".. obj.name .."' requested registration for event `".. eventName .."' but does not have the appropriate callback method")
        end
    end
end


function Xist_Addon:Init()
    self:InitializeEvents()
end


function Xist_Addon:GetName()
    return self.name
end


function Xist_Addon:GetVersion()
    return self.version
end


function Xist_Addon:AddSlashCommand(commandName)
    local n = 1 + #self.slashCommands
    local addonIdent = string.upper(self.name)
    local globalName = "SLASH_".. addonIdent .. n
    _G[globalName] = "/".. commandName
end


function Xist_Addon:SetSlashCommandHandler(callback)
    local addonIdent = string.upper(self.name)
    _G.SlashCmdList[addonIdent] = callback
end


function Xist_Addon:GetAddonMessagePrefix()
    local prefix = self.name
    -- if this prefix is too long then we can't use it!
    if strlen(prefix) > 16 then -- don't remember where I saw this 16 character limit...
        WARNING("Addon prefix `".. prefix .."' is too long to use Addon messages")
        return nil
    end
    return prefix
end


--- @param callback fun|nil
function Xist_Addon:OnLoad(callback)
    self.OnLoadCallback = callback
end


--- @param callback fun|nil
function Xist_Addon:OnLogout(callback)
    self.OnLogoutCallback = callback
end


--- An addon has loaded.
--- @param name string name of the addon that loaded (maybe not our addon)
--- @see https://wow.gamepedia.com/AddOn_loading_process
function Xist_Addon:ADDON_LOADED(name)
    if name == self.name then
        -- our own addon has loaded
        DEBUG("ADDON_LOADED [ME]", name)

        if self.OnLoadCallback then
            self.OnLoadCallback()
        end

        if self.bAnnounceLoad then
            self.protected.MESSAGE("version", tostring(self.version), "loaded")
        end
    else
        DEBUG("ADDON_LOADED", name)
    end
end


function Xist_Addon:PLAYER_LOGOUT()
    DEBUG("PLAYER_LOGOUT")
    if self.OnLogoutCallback then
        self.OnLogoutCallback()
    end
end


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
    DEBUG("PLAYER_ENTERING_WORLD", {isInitialLogin=isInitialLogin, isReloadingUI=isReloadingUI})

    -- Register for my own addon messages
    local prefix = self:GetAddonMessagePrefix()
    if prefix then
        DEBUG("Using prefix `".. prefix .."' for Addon messages")
        C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    end
end


-- By default addons ignore messages
Xist_Addon.OnMyAddonMessageReceived = protected.NOOP
Xist_Addon.OnOtherAddonMessageReceived = protected.NOOP


function Xist_Addon:SendAddonMessage(message)
    C_ChatInfo.SendAddonMessage(self:GetAddonMessagePrefix(), message, "GUILD", nil)
end
