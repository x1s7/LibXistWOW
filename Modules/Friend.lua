
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


function Xist_Friend:IsFriend()
    return self.ToonInfo and self.ToonInfo.isFriend
end


function Xist_Friend:IsBattleNetFriend()
    return self:GetBattleTag() ~= nil
end


function Xist_Friend:GetName(wantFullName)
    if self.ToonInfo then
        if wantFullName then
            return self.ToonInfo.name .."-".. PLAYER_REALM
        end
        return self.ToonInfo.name
    end
    return nil
end


function Xist_Friend:GetGUID()
    if self.ToonInfo then
        return self.ToonInfo.guid
    end
    return nil
end


function Xist_Friend:IsOnline()
    if self.ToonInfo then
        return self.ToonInfo.connected
    end
    return false
end


function Xist_Friend:IsInGame()
    return self:IsOnline()
end
