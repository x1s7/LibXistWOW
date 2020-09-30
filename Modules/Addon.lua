
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

    local log = Xist_Log:New(name)

    obj.protected = {
        DEBUG = log:Proxy('LogDebug'),
        DEBUG_DUMP = log:Proxy('LogDebugDump'),
        ERROR = log:Proxy('LogError'),
        MESSAGE = log:Proxy('LogMessage'),
        WARNING = log:Proxy('LogWarning'),
    }

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

    obj.name = name
    obj.version = Xist_Version:New(version)
    obj.slashCommands = {}

    obj.announceLoad = false

    AddonInstances[name] = obj -- keep track of this instance by name
    return obj
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
    return self.name
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
        DEBUG("ADDON_LOADED [ME] ".. name)

        if self.OnLoadCallback then
            self.OnLoadCallback()
        end

        if self.announceLoad then
            self.protected.MESSAGE("Loaded version ".. tostring(self.version))
        end
    else
        DEBUG("ADDON_LOADED ".. name)
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
    if strlen(prefix) <= 16 then
        C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    else
        WARNING("Addon prefix `".. prefix .."' is too long to use Addon messages")
    end
end


-- By default addons ignore messages
Xist_Addon.OnMyAddonMessageReceived = protected.NOOP
Xist_Addon.OnOtherAddonMessageReceived = protected.NOOP


function Xist_Addon:SendAddonMessage(message)
    C_ChatInfo.SendAddonMessage(self:GetAddonMessagePrefix(), message, "GUILD", nil)
end
