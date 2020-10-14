
local ModuleName = "Xist_EventHandler"
local ModuleVersion = 1

-- If some other addon installed Xist_EventHandler, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_EventHandler
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_EventHandler
Xist_EventHandler = M

--protected.DebugEnabled = true

local DEBUG_CHAT_MSG_ADDON = false

local DEBUG_CAT = protected.DEBUG_CAT
local ERROR = protected.ERROR
local WARNING = protected.WARNING

protected.GLOBAL_EVENTS = {

    -- Events triggered by WOW itself:

    ADDON_LOADED = {}, -- one of the many addons has loaded, saved data is now available
    FRIENDLIST_UPDATE = {}, -- new/updated information about the friends list is available
    PLAYER_ENTERING_WORLD = {}, -- player is entering the world
    PLAYER_LOGOUT = {}, -- player is logging out, time to save persistent data
    PLAYER_REGEN_ENABLED = {}, -- combat has ended
    PLAYER_REGEN_DISABLED = {}, -- combat has begun

    -- XIST_* events are custom to LibXistWOW:

    XIST_COMBAT_ENDED = {}, -- combat has ended -- callback(combatDurationSeconds)
    XIST_COMBAT_STARTED = {}, -- combat has started
}

protected.ADDON_SPECIFIC_EVENTS = {
    OnLoad = {}, -- this specific addon has loaded -- callback(AddonName)
    OnSaveDataRead = {}, -- save data has been read -- callback(SavedData)
    OnSaveDataWrite = {}, -- need to write any changes to save data
}

protected.SLIDER_SPECIFIC_EVENTS = {
    OnValueChanged = {} -- any time the value of the slider changes -- callback(value, delta)
}


local _GlobalFrame = CreateFrame("FRAME", nil, UIParent)
local _GlobalInstance

Xist_EventHandler.isStatic = true


--- @return Xist_EventHandler
function Xist_EventHandler:New()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.ident = "Global"
    obj.KnownEvents = protected.GLOBAL_EVENTS -- by default the global events are allowed
    obj.RegisteredEvents = {}
    obj.isStatic = false -- this object has been instantiated
    obj.isGlobal = true

    return obj
end


--- @param name string Name of this event handler (e.g. Addon name)
--- @return Xist_EventHandler
function Xist_EventHandler:NewAddonHandler(name)
    local obj = self:New()
    obj.ident = name
    obj.KnownEvents = protected.ADDON_SPECIFIC_EVENTS -- addon specific handler uses addon specific events
    obj.isGlobal = false
    return obj
end


--- @return Xist_EventHandler
function Xist_EventHandler:NewSliderHandler()
    local obj = self:New()
    obj.ident = 'Xist_UI_Slider'
    obj.KnownEvents = protected.SLIDER_SPECIFIC_EVENTS
    obj.isGlobal = false
    return obj
end


function Xist_EventHandler:GlobalInstance()
    if not _GlobalInstance then
        _GlobalInstance = self:New()
    end
    return _GlobalInstance
end


--- Register a callback for an event.
--- @param eventName string
--- @param callback fun(string)
function Xist_EventHandler:RegisterEvent(eventName, callback)

    -- If this method was invoked as static, then use the global instance
    if self.isStatic then
        self = self:GlobalInstance()
    end

    -- if eventName is not a known event name then error
    if not self.KnownEvents[eventName] then
        -- if this begins with CHAT_MSG_ then just register it, there are so many...
        if string.sub(eventName, 1, 9) == "CHAT_MSG_" then
            --DEBUG("Dynamically added support for ".. eventName)
            self.KnownEvents[eventName] = {}
        else
            -- programmer error, eventName is not a valid event name
            ERROR("Invalid Event ID:", eventName)
            error("Invalid Event ID: " .. eventName)
        end
    end

    -- initialize scope for this event if needed
    if self.RegisteredEvents[eventName] == nil then
        self.RegisteredEvents[eventName] = {}
    end
    local eventInfo = self.RegisteredEvents[eventName]

    -- if we haven't yet registered in the global frame for this event, do so now
    if not eventInfo.isRegistered then
        eventInfo.isRegistered = true
        -- events starting with XIST_ are meta events; don't try to register those
        if self.isGlobal and string.sub(eventName, 1, 5) ~= "XIST_" then
            _GlobalFrame:RegisterEvent(eventName)
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

    -- If this method was invoked as static, then use the global instance
    if self.isStatic then
        self = self:GlobalInstance()
    end

    -- debug all events EXCEPT CHAT_MSG_ADDON; that one requires a special toggle since it is quite verbose
    if eventName ~= "CHAT_MSG_ADDON" or DEBUG_CHAT_MSG_ADDON then
        DEBUG_CAT(self.ident, "TriggerEvent", {eventName=eventName}, Xist_Util.ToList(...))
    end

    -- if eventName is a known event then execute its callbacks (if any)
    local eventInfo = self.RegisteredEvents[eventName]
    if eventInfo and eventInfo.callbacks then
        if self.isGlobal then
            -- The global event handler always passes the name of the event as the first
            -- argument, consistent with how WOW itself handles events.
            for _, callback in ipairs(eventInfo.callbacks) do
                callback(eventName, ...)
            end
        else
            -- Object-specific event handlers do not pass the name of the event, and instead
            -- just give the event arguments.
            for _, callback in ipairs(eventInfo.callbacks) do
                callback(...)
            end
        end
    end
end


_GlobalFrame:SetScript("OnEvent", function(_, ...) -- first argument is reference to _GlobalFrame, ignore it
    Xist_EventHandler:TriggerEvent(...)
end)
