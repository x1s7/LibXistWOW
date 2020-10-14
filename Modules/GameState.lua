
local ModuleName = "Xist_GameState"
local ModuleVersion = 1

-- If some other addon installed Xist_GameState, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_GameState
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_GameState
Xist_GameState = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local DEBUG_DUMP = protected.DEBUG_DUMP
local MESSAGE = protected.MESSAGE
local WARNING = protected.WARNING

local inCombat = false
local combatStartTime = 0
local combatStopTime = 0


function Xist_GameState:New()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end


function Xist_GameState:IsInCombat()
    return inCombat
end


function Xist_GameState:GetCombatDuration()
    local t = inCombat and time() or combatStopTime
    return t - combatStartTime
end


local function OnRegenEnabled()
    -- regen is enabled, combat has ended
    inCombat = false
    combatStopTime = time()
    -- Redisplay Xist_UI
    Xist_UI.UIParent:Show()
    -- trigger the event in the global scope for all addons
    Xist_EventHandler:TriggerEvent("XIST_COMBAT_ENDED", combatStopTime - combatStartTime)
end


local function OnRegenDisabled()
    -- regen has been disabled, combat has started
    inCombat = true
    combatStartTime = time()
    -- Hide Xist_UI
    Xist_UI.UIParent:Hide()
    -- trigger the event in the global scope for all addons
    Xist_EventHandler:TriggerEvent("XIST_COMBAT_STARTED")
end


Xist_EventHandler:RegisterEvent("PLAYER_REGEN_ENABLED", OnRegenEnabled)
Xist_EventHandler:RegisterEvent("PLAYER_REGEN_DISABLED", OnRegenDisabled)
