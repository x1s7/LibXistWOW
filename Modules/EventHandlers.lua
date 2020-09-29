
local ModuleName = "Xist_EventHandlers"
local ModuleVersion = 1

-- If some other addon installed Xist_EventHandlers, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_EventHandlers
local M, protected = Xist_Module.AddModule(ModuleName, ModuleVersion)

--- @class Xist_EventHandlers
Xist_EventHandlers = M

--protected.DebugEnabled = true

local ERROR = protected.ERROR

protected.Events = {
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


--- Register a callback for an event.
--- @param eventName string
--- @param callback fun(string)
function Xist_EventHandlers.RegisterEvent(eventName, callback)
    -- if eventName is a known event then register callback
    if protected.Events[eventName] ~= nil then
        if protected.Events[eventName].callbacks == nil then
            protected.Events[eventName].callbacks = {}
        end
        table.insert(protected.Events[eventName].callbacks, callback)
    else
        -- programmer error, eventName is not a valid event name
        ERROR("Invalid Event ID:", eventName)
        error("Invalid Event ID: " .. eventName)
    end
end


function Xist_EventHandlers.TriggerEvent(eventName)
    -- if eventName is a known event then execute its callbacks (if any)
    if protected.Events[eventName] ~= nil then
        if protected.Events[eventName].callbacks ~= nil then
            for _, callback in ipairs(protected.Events[eventName].callbacks) do
                callback(eventName)
            end
        end
    else
        -- programmer error, eventName is not a valid event name
        ERROR("Invalid Event ID:", eventName)
        error("Invalid Event ID: " .. eventName)
    end
end
