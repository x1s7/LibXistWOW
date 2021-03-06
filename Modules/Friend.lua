
local ModuleName = "Xist_Friend"
local ModuleVersion = 1

-- If some other addon installed Xist_Friend, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Friend
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_Friend
Xist_Friend = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local DEBUG_DUMP = protected.DEBUG_DUMP
local MESSAGE = protected.MESSAGE
local WARNING = protected.WARNING

local PLAYER_REALM = GetRealmName()


function Xist_Friend:New()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end


function Xist_Friend:NewByIndex(index)
    local obj = self:New()
    obj.index = index
    -- @see https://wow.gamepedia.com/API_C_FriendList.GetFriendInfo
    obj.ToonInfo = C_FriendList and C_FriendList.GetFriendInfoByIndex(index)
    DEBUG("NewByIndex =", obj.ToonInfo)
    return obj
end


function Xist_Friend:GetIndex()
    return self.index
end


function Xist_Friend:GetBattleTag()
    return nil
end


function Xist_Friend:GetInternalDataKey(key, default)
    if self.ToonInfo then
        if self.ToonInfo[key] ~= nil then
            DEBUG("GetInternalDataKey `".. key .."' =", self.ToonInfo[key])
            return self.ToonInfo[key]
        else
            DEBUG("GetInternalDataKey `".. key .."' is nil")
        end
    else
        DEBUG("GetInternalDataKey `".. key .."' before loading ToonInfo")
    end
    return default
end


--- Is this friend a friend?
--- In the case of a Toon friend, all friends added as contacts are friends.
--- @return boolean
function Xist_Friend:IsFriend()
    return true
end


--- Is this a BattleNet friend?
--- For toon friends this will always return false since GetBattleTag() returns nil for toon friends.
--- Xist_Friend_BattleNet overrides GetBattleTag() to return non-nil, which then makes this return true.
--- @return boolean
function Xist_Friend:IsBattleNetFriend()
    return self:GetBattleTag() ~= nil
end


--- Get this friend's name.
--- For a toon friend, this is the same as their toon name.
--- @param wantFullName boolean
--- @return string|nil
function Xist_Friend:GetName(wantFullName)
    if self.ToonInfo then
        if wantFullName then
            return self.ToonInfo.name .."-".. PLAYER_REALM
        end
        return self.ToonInfo.name
    end
    return nil
end


--- Get the name of this friend's current toon.
Xist_Friend.GetToonName = Xist_Friend.GetName


function Xist_Friend:GetGUID()
    return self:GetInternalDataKey("guid", false)
end


--- Is the friend currently online?
--- @return boolean
function Xist_Friend:IsOnline()
    return self:GetInternalDataKey("connected", false)
end


--- Is the friend currently in game?
--- For toon friends this always returns true if they are online.
--- @return boolean
function Xist_Friend:IsInGame()
    return self:IsOnline()
end
