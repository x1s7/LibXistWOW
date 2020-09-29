
local AddonName = ...

local ModuleName = "Xist_GameState"
local ModuleVersion = 1

-- If some other addon installed Xist_GameState, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_GameState
local M, protected = Xist_Module.AddModule(ModuleName, ModuleVersion)

--- @class Xist_GameState
Xist_GameState = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local DEBUG_DUMP = protected.DEBUG_DUMP
local MESSAGE = protected.MESSAGE
local WARNING = protected.WARNING

local inCombat = false


function Xist_GameState:New()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end


function Xist_GameState:IsInCombat()
    return inCombat
end


local function OnRegenEnabled()
    -- regen is enabled, combat has ended
    inCombat = false
    Xist_EventHandlers.TriggerEvent("XIST_COMBAT_ENDED")
end


local function OnRegenDisabled()
    -- regen has been disabled, combat has started
    inCombat = true
    Xist_EventHandlers.TriggerEvent("XIST_COMBAT_STARTED")
end


Xist_EventHandlers.RegisterEvent("PLAYER_ENTERING_WORLD", function()
    -- Keep track of combat state
    local addon = Xist_Addon.Instance(AddonName)
    addon:RegisterEvent("PLAYER_REGEN_ENABLED", OnRegenEnabled)
    addon:RegisterEvent("PLAYER_REGEN_DISABLED", OnRegenDisabled)
end)
