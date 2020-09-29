
local ModuleName = "Xist_FriendsList"
local ModuleVersion = 1

-- If some other addon installed Xist_FriendsList, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_FriendsList
local M, protected = Xist_Module.AddModule(ModuleName, ModuleVersion)

--- @class Xist_FriendsList
Xist_FriendsList = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local DEBUG_DUMP = protected.DEBUG_DUMP
local MESSAGE = protected.MESSAGE
local WARNING = protected.WARNING

local AddonName = ...

local _instance


function Xist_FriendsList:Instance()
    if _instance then return _instance end

    _instance = {}
    setmetatable(_instance, self)
    self.__index = self

    return _instance
end


function Xist_FriendsList:GetNumToonFriends()
    return C_FriendList.GetNumFriends()
end


function Xist_FriendsList:GetNumBNetFriends()
    return BNGetNumFriends() -- return the total
end


function Xist_FriendsList:IterateToonFriends()
    local i = 0
    local n = self:GetNumToonFriends()
    return function()
        i = i + 1
        if i <= n then
            return Xist_Friend:NewByIndex(i)
        end
    end
end


function Xist_FriendsList:IterateBNetFriends()
    local i = 0
    local n = self:GetNumBNetFriends()
    return function()
        i = i + 1
        if i <= n then
            return Xist_Friend:NewByBNetIndex(i)
        end
    end
end


function Xist_FriendsList:IterateFriends()
    local i = 0
    local n1 = self:GetNumToonFriends()
    local n2 = self:GetNumBNetFriends()
    return function()
        i = i + 1
        if i <= n1 then
            return Xist_Friend:NewByIndex(i)
        elseif i <= n2 then
            return Xist_Friend:NewByBNetIndex(i - n1)
        end
    end
end


function Xist_FriendsList:IsFriend(name)
    for friend in self:IterateFriends() do
        if friend:GetName() == name then
            return friend:IsFriend()
        end
    end
    return false
end


function Xist_FriendsList:IsBNetFriend(name)
    for friend in self:IterateBNetFriends() do
        if friend:GetName() == name then
            return friend:IsBNetFriend()
        end
    end
    return false
end


local function OnFriendListUpdate()
    --DEBUG("Friends list update")

    --[[
    for friend in Xist_FriendsList:IterateFriends() do
        DEBUG("FRIEND", {
            name = friend:GetName(),
            isFriend = friend:IsFriend(),
            isBNetFriend = friend:IsBNetFriend(),
            guid = friend:GetGUID(),
        })
    end

    for friend in Xist_FriendsList:IterateBNetFriends() do
        DEBUG("BNET_FRIEND", {
            name = friend:GetName(),
            battleTag = friend:GetBattleTag(),
            isFriend = friend:IsFriend(),
            isBNetFriend = friend:IsBNetFriend(),
            guid = friend:GetGUID(),
        })
    end
    --]]
end


Xist_EventHandlers.RegisterEvent("PLAYER_ENTERING_WORLD", function()
    DEBUG("Requesting friends list update")
    -- every login/reload request updated friends list info
    Xist_Addon.Instance(AddonName):RegisterEvent("FRIENDLIST_UPDATE", OnFriendListUpdate)
    C_FriendList.ShowFriends() -- fires FRIENDLIST_UPDATE when complete
end)
