
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

local _instance


function Xist_FriendsList:Instance()
    if _instance then return _instance end

    _instance = {}
    setmetatable(_instance, self)
    self.__index = self

    -- to begin with, cache is dirty; must query server
    _instance.dirty = true

    return _instance
end


function Xist_FriendsList:GetNumToonFriends()
    return C_FriendList.GetNumFriends()
end


function Xist_FriendsList:GetNumBNetFriends()
    return BNGetNumFriends() -- return the total
end


function Xist_FriendsList:IterateToonFriends(queryServer)
    local instance = self:Instance()
    -- if local memory is dirty and we want to use local memory rather than querying the server,
    -- then we need to clean up the dirty mess before we use it!
    if instance.dirty and not queryServer then
        self:Cleanup()
    end
    local i = 0
    local n = self:GetNumToonFriends()
    return function()
        i = i + 1
        if i <= n then
            if queryServer then
                return Xist_Friend:NewByIndex(i)
            end
            return instance.ToonFriends[i]
        end
    end
end


function Xist_FriendsList:IterateBNetFriends(queryServer)
    local instance = self:Instance()
    -- if local memory is dirty and we want to use local memory rather than querying the server,
    -- then we need to clean up the dirty mess before we use it!
    if instance.dirty and not queryServer then
        self:Cleanup()
    end
    local i = 0
    local n = self:GetNumBNetFriends()
    return function()
        i = i + 1
        if i <= n then
            if queryServer then
                return Xist_Friend:NewByBNetIndex(i)
            end
            return instance.BNetFriends[i]
        end
    end
end


function Xist_FriendsList:IterateFriends(queryServer)
    local instance = self:Instance()
    -- if local memory is dirty and we want to use local memory rather than querying the server,
    -- then we need to clean up the dirty mess before we use it!
    if instance.dirty and not queryServer then
        self:Cleanup()
    end
    local i = 0
    local n1 = self:GetNumToonFriends()
    local n2 = self:GetNumBNetFriends()
    return function()
        i = i + 1
        if i <= n1 then
            if queryServer then
                return Xist_Friend:NewByIndex(i)
            end
            return instance.ToonFriends[i]
        elseif i <= n2 then
            if queryServer then
                return Xist_Friend:NewByBNetIndex(i - n1)
            end
            return instance.BNetFriends[i - n1]
        end
    end
end


function Xist_FriendsList:Cleanup()
    local instance = Xist_FriendsList:Instance()
    if instance.dirty then
        instance.dirty = false -- clear instance.dirty BEFORE iterating over friends

        DEBUG("Syncing cache with server friends info")

        instance.ToonFriends = {}
        for friend in Xist_FriendsList:IterateToonFriends(true) do
            table.insert(instance.ToonFriends, friend)
        end

        instance.BNetFriends = {}
        for friend in Xist_FriendsList:IterateBNetFriends(true) do
            table.insert(instance.BNetFriends, friend)
        end
    end
end


function Xist_FriendsList:IsToonFriend(name)
    for friend in self:IterateToonFriends() do
        if friend:GetName() == name then
            return friend:IsToonFriend()
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


function Xist_FriendsList:IsFriend(name)
    return self:IsToonFriend(name) or self:IsBNetFriend(name)
end


local function OnFriendListUpdate()
    DEBUG("Friends list updated")
    Xist_FriendsList:Instance().dirty = true
end


local function OnPlayerEnteringWorld()
    DEBUG("Requesting friends list update")
    C_FriendList.ShowFriends() -- fires FRIENDLIST_UPDATE when complete
end


Xist_EventHandler:RegisterEvent("FRIENDLIST_UPDATE", OnFriendListUpdate)
Xist_EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
