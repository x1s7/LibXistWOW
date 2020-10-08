
local ModuleName = "Xist_FriendsList"
local ModuleVersion = 1

-- If some other addon installed Xist_FriendsList, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_FriendsList
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_FriendsList
Xist_FriendsList = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local DEBUG_DUMP = protected.DEBUG_DUMP
local MESSAGE = protected.MESSAGE
local WARNING = protected.WARNING

local _instance

local WANT_VERBOSE_DEBUG = false

local function VERBOSE_DEBUG(...)
    if WANT_VERBOSE_DEBUG then
        DEBUG(...)
    end
end


function Xist_FriendsList:Instance()
    if _instance then return _instance end

    _instance = {}
    setmetatable(_instance, self)
    self.__index = self

    -- to begin with, cache is dirty; must query server
    _instance.dirty = true

    return _instance
end


function Xist_FriendsList:IterateToonFriends()
    local instance = self:Instance()

    -- if we need to refresh from the server, do it before we start to iterate
    if instance.dirty then self:Cleanup() end

    -- iterate through the stored list of friends
    local i = 0
    return function()
        if i < #instance.ToonFriends then
            i = i + 1
            return instance.ToonFriends[i]
        end
    end
end


function Xist_FriendsList:IterateBNetFriends()
    local instance = self:Instance()

    -- if we need to refresh from the server, do it before we start to iterate
    if instance.dirty then self:Cleanup() end

    -- iterate through the stored list of friends
    local i = 0
    return function()
        if i < #instance.BNetFriends then
            i = i + 1
            return instance.BNetFriends[i]
        end
    end
end


function Xist_FriendsList:IterateFriends()
    local instance = self:Instance()

    -- if we need to refresh from the server, do it before we start to iterate
    if instance.dirty then self:Cleanup() end

    local i, j = 0, 0
    return function()
        if i < #instance.ToonFriends then
            i = i + 1
            return instance.ToonFriends[i]
        elseif j < #instance.BNetFriends then
            j = j + 1
            return instance.BNetFriends[j]
        end
    end
end


function Xist_FriendsList:Cleanup()
    local instance = Xist_FriendsList:Instance()
    if instance.dirty then
        instance.dirty = false -- clear instance.dirty BEFORE iterating over friends

        DEBUG("Syncing with server")

        instance.ToonFriends = {}
        local n = C_FriendList.GetNumFriends()
        local friend
        for i = 1, n do
            friend = Xist_Friend:NewByIndex(i)
            VERBOSE_DEBUG("[".. i .."] Toon friend:", {name=friend:GetName(), inGame=friend:IsInGame(), battleTag=friend:GetBattleTag()})
            instance.ToonFriends[i] = friend
        end

        instance.BNetFriends = {}
        n = BNGetNumFriends()
        for i = 1, n do
            friend = Xist_Friend_BattleNet:NewByIndex(i)
            VERBOSE_DEBUG("[".. i .."] BattleNet friend:", {name=friend:GetName(), inGame=friend:IsInGame(), battleTag=friend:GetBattleTag()})
            instance.BNetFriends[i] = friend
        end
    end
end


function Xist_FriendsList:GetToonFriend(fullName)
    for friend in self:IterateToonFriends() do
        if friend:GetName(true) == fullName then
            DEBUG("Found toon friend `".. fullName .."'")
            return friend
        end
    end
    DEBUG("No such toon friend `".. fullName .."'")
    return nil
end


function Xist_FriendsList:GetBNetFriend(fullName)
    for friend in self:IterateBNetFriends() do
        if friend:GetToonName(true) == fullName then
            DEBUG("Found BNet friend `".. fullName .."'")
            return friend
        end
    end
    DEBUG("No such BNet friend `".. fullName .."'")
    return nil
end


function Xist_FriendsList:IsToonFriend(fullName)
    local friend = self:GetToonFriend(fullName)
    if friend then return friend:IsFriend() end
    return false
end


function Xist_FriendsList:IsBNetFriend(fullName)
    local friend = self:GetBNetFriend(fullName)
    if friend then return friend:IsFriend() end
    return false
end


function Xist_FriendsList:GetFriend(fullName)
    -- search for a toon friend first, otherwise a BNet friend
    return self:GetToonFriend(fullName) or self:GetBNetFriend(fullName) -- possibly nil
end


function Xist_FriendsList:IsFriend(fullName)
    local friend = self:GetFriend(fullName)
    if friend then return friend:IsFriend() end
    return false
end


--- Mark cached friends list as dirty when game notifies us of updates.
local function OnFriendListUpdate()
    DEBUG("Server notified of friends list update")
    Xist_FriendsList:Instance().dirty = true
end


--- Request server to send the most updated friends info.
local function OnPlayerEnteringWorld()
    DEBUG("Queueing friends list update")
    C_FriendList.ShowFriends() -- fires FRIENDLIST_UPDATE when complete
end


Xist_EventHandler:RegisterEvent("FRIENDLIST_UPDATE", OnFriendListUpdate)
Xist_EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
