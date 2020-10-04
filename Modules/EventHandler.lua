
local ModuleName = "Xist_EventHandler"
local ModuleVersion = 1

-- If some other addon installed Xist_EventHandler, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_EventHandler
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_EventHandler
Xist_EventHandler = M

protected.DebugEnabled = true

local DEBUG_CHAT_MSG_ADDON = false

local DEBUG_CAT = protected.DEBUG_CAT
local ERROR = protected.ERROR
local WARNING = protected.WARNING

protected.SUPPORTED_EVENTS = {
    ADDON_LOADED = {}, -- addon has loaded, saved data is now available
    FRIENDLIST_UPDATE = {}, -- new/updated information about the friends list is available
    PLAYER_ENTERING_WORLD = {}, -- player is entering the world
    PLAYER_LOGOUT = {}, -- player is logging out, time to save persistent data
    PLAYER_REGEN_ENABLED = {}, -- combat has ended
    PLAYER_REGEN_DISABLED = {}, -- combat has begun
    XIST_COMBAT_ENDED = {}, -- combat has ended
    XIST_COMBAT_STARTED = {}, -- combat has started
    XIST_PLAYER_ENTERING_WORLD_LOGIN = {}, -- called only on initial login
    XIST_PLAYER_ENTERING_WORLD_RELOAD = {}, -- called only when /reload is issued
    XIST_PRE_ADDON_LOADED = {}, -- fires just before ADDON_LOADED
}

local globalFrame = CreateFrame("FRAME", nil, UIParent)
local _instance


Xist_EventHandler.isStatic = true


function Xist_EventHandler:New()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.Events = {}
    obj.isStatic = false -- this object has been instantiated

    return obj
end


function Xist_EventHandler:Instance()
    if not _instance then
        _instance = self:New()
    end
    return _instance
end


--- Register a callback for an event.
--- @param eventName string
--- @param callback fun(string)
function Xist_EventHandler:RegisterEvent(eventName, callback)

    -- If this method was invoked as static, then use the global instance
    if self.isStatic then
        self = self:Instance()
    end

    -- if eventName is not a known event name then error
    if not protected.SUPPORTED_EVENTS[eventName] then
        -- if this begins with CHAT_MSG_ then just register it, there are so many...
        if string.sub(eventName, 1, 9) == "CHAT_MSG_" then
            --DEBUG("Dynamically added support for ".. eventName)
            protected.SUPPORTED_EVENTS[eventName] = {}
        else
            -- programmer error, eventName is not a valid event name
            ERROR("Invalid Event ID:", eventName)
            error("Invalid Event ID: " .. eventName)
        end
    end

    -- initialize scope for this event if needed
    if self.Events[eventName] == nil then
        self.Events[eventName] = {}
    end
    local eventInfo = self.Events[eventName]

    -- if we haven't yet registered in the global frame for this event, do so now
    if not eventInfo.isRegistered then
        eventInfo.isRegistered = true
        -- events starting with XIST_ are meta events; don't try to register those
        if string.sub(eventName, 1, 5) ~= "XIST_" then
            globalFrame:RegisterEvent(eventName)
        end
    end

    -- initialize callbacks for this event if needed
    if eventInfo.callbacks == nil then
        eventInfo.callbacks = {}
    end
    local registeredCallbacks = eventInfo.callbacks

    -- some callbacks are already installed.
    -- check to see if this callback already exists, and if so don't add it a second time.
    for _, f in ipairs(registeredCallbacks) do
        if f == callback then
            -- callback is already registered
            WARNING("RegisterEvent", eventName, {duplicate=true})
            return
        end
    end

    -- add this new event callback
    table.insert(registeredCallbacks, callback)

    DEBUG_CAT(self.ident, "RegisterEvent", eventName)
end


function Xist_EventHandler:TriggerEvent(eventName, ...)

    -- debug all events EXCEPT CHAT_MSG_ADDON; that one requires a special toggle since it is quite verbose
    if eventName ~= "CHAT_MSG_ADDON" or DEBUG_CHAT_MSG_ADDON then
        DEBUG_CAT(self.ident, "TriggerEvent", {eventName=eventName}, Xist_Util.ToList(...))
    end

    -- If this method was invoked as static, then use the global instance
    if self.isStatic then
        self = self:Instance()
    end

    -- if eventName is a known event then execute its callbacks (if any)
    local eventInfo = self.Events[eventName]
    if eventInfo and eventInfo.callbacks then
        for _, callback in ipairs(eventInfo.callbacks) do
            callback(eventName, ...)
        end
    end
end


globalFrame:SetScript("OnEvent", function(_, ...) -- first argument is reference to globalFrame, ignore it
    Xist_EventHandler:TriggerEvent(...)
end)
