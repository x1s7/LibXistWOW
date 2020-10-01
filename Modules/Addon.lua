
local AddonName = ...

local ModuleName = "Xist_Addon"
local ModuleVersion = 1

-- If some other addon installed Xist_Addon, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Addon
local M, protected = Xist_Module.AddModule(ModuleName, ModuleVersion)

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

    obj:InitializeEvents()

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


function Xist_Addon:InitializeEvents()

    local obj = self

    local objSpecificEventCallback = function(eventName, ...)
        return obj[eventName](obj, ...)
    end

    local defaultEvents = {
        "ADDON_LOADED",
        "CHAT_MSG_ADDON",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_LOGOUT",
    }

    for _, eventName in ipairs(defaultEvents) do
        Xist_EventHandler:RegisterEvent(eventName, objSpecificEventCallback)
    end
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


function Xist_Addon:OnLoad(callback)
    self.OnLoadCallback = callback
end


function Xist_Addon:OnLogout(callback)
    self.OnLogoutCallback = callback
end


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


function Xist_Addon:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUI)
    DEBUG("PLAYER_ENTERING_WORLD", {isInitialLogin=isInitialLogin, isReloadingUI=isReloadingUI})

    -- Register for my own addon messages
    local prefix = self:GetAddonMessagePrefix()
    if prefix then
        WARNING("Using prefix `".. prefix .."' for Addon messages")
        C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    end
end


-- By default addons ignore messages
Xist_Addon.OnMyAddonMessageReceived = protected.NOOP
Xist_Addon.OnOtherAddonMessageReceived = protected.NOOP


function Xist_Addon:SendAddonMessage(message)
    C_ChatInfo.SendAddonMessage(self:GetAddonMessagePrefix(), message, "GUILD", nil)
end
