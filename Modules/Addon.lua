
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


protected.OnFrameEvent = function(self, eventName, ...)

    --DEBUG("OnFrameEvent", eventName)

    local addon = self.Xist_Addon
    if addon and addon[eventName] then
        return addon[eventName](addon, ...)
    end
end


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

    obj.protected = {
        DEBUG = function(...) Xist_Log.DEBUG(nil, ...) end, -- debug without type info (main addon)
        DEBUG_DUMP = function(...) Xist_Log.DEBUG_DUMP(nil, ...) end, -- debug without type info (main addon)
        ERROR = Xist_Log.ERROR,
        MESSAGE = Xist_Log.MESSAGE,
        WARNING = Xist_Log.WARNING,
    }

    local frame = CreateFrame("FRAME", nil, UIParent)

    frame:SetFrameStrata("BACKGROUND")
    frame:SetScript("OnEvent", protected.OnFrameEvent);

    frame:RegisterEvent("ADDON_LOADED")
    frame:RegisterEvent("CHAT_MSG_ADDON")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("PLAYER_LOGOUT")

    obj.name = name
    obj.version = Xist_Version:New(version)
    obj.frame = frame
    obj.slashCommands = {}

    frame.Xist_Addon = obj -- hook frame to self

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


function Xist_Addon:RegisterEvent(eventName, callback)
    Xist_EventHandlers.RegisterEvent(eventName, callback)
    -- if we don't already have a handler for this event, create a default one
    -- that simply triggers Xist_EventHandlers for other modules
    if not self[eventName] then
        self[eventName] = function()
            Xist_EventHandlers.TriggerEvent(eventName)
        end
    end
    self.frame:RegisterEvent(eventName)
end


function Xist_Addon:GetAddonMessagePrefix()
    return self.name
end


function Xist_Addon:ADDON_LOADED(name)
    if name == self.name then
        -- our own addon has loaded
        --DEBUG("ADDON_LOADED")

        -- fire the XIST_PRE_ADDON_LOADED event
        Xist_EventHandlers.TriggerEvent("XIST_PRE_ADDON_LOADED")

        -- fire the ADDON_LOADED event
        Xist_EventHandlers.TriggerEvent("ADDON_LOADED")
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
    --DEBUG("PLAYER_ENTERING_WORLD", {isInitialLogin=isInitialLogin, isReloadingUI=isReloadingUI})

    -- Register for my own addon messages
    local prefix = self:GetAddonMessagePrefix()
    if strlen(prefix) <= 16 then
        C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    else
        WARNING("Addon prefix `".. prefix .."' is too long to use Addon messages")
    end

    -- specific initial login event
    if isInitialLogin then
        Xist_EventHandlers.TriggerEvent("XIST_PLAYER_ENTERING_WORLD_LOGIN")
    end

    -- specific reload ui event
    if isReloadingUI then
        Xist_EventHandlers.TriggerEvent("XIST_PLAYER_ENTERING_WORLD_RELOAD")
    end

    -- fire the generic event after the specific events
    Xist_EventHandlers.TriggerEvent("PLAYER_ENTERING_WORLD")
end


function Xist_Addon:PLAYER_LOGOUT()
    Xist_EventHandlers.TriggerEvent("PLAYER_LOGOUT")
end


function Xist_Addon:SetEventHandler(eventName, callback)
    self[eventName] = callback
    self.frame:RegisterEvent(eventName)
end


-- By default addons ignore messages
Xist_Addon.OnMyAddonMessageReceived = protected.NOOP
Xist_Addon.OnOtherAddonMessageReceived = protected.NOOP


function Xist_Addon:SendAddonMessage(message)
    C_ChatInfo.SendAddonMessage(self:GetAddonMessagePrefix(), message, "GUILD", nil)
end
