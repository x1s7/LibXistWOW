
local ModuleName = "Xist_Friend"
local ModuleVersion = 1

-- If some other addon installed Xist_Friend, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Friend
local M, protected = Xist_Module.AddModule(ModuleName, ModuleVersion)

--- @class Xist_Friend
Xist_Friend = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local DEBUG_DUMP = protected.DEBUG_DUMP
local MESSAGE = protected.MESSAGE
local WARNING = protected.WARNING


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


function Xist_Friend:NewByBNetIndex(index)
    local obj = self:New()
    obj.index = index
    obj.BNet = true
    if C_BattleNet and C_BattleNet.GetFriendAccountInfo then
        obj.BNetInfo = C_BattleNet.GetFriendAccountInfo(index)
    else
        local presenceID, accountName, battleTag, _, characterName, bnetAccountId, client,
        isOnline, lastOnline, isAFK, isDND, _, _, _, _, wowProjectID, _, _,
        isFavorite, mobile = BNGetFriendInfo(index)

        local gai
        if isOnline then
            local _, _, _, realmName, realmID, faction, _, class, _, zoneName, level,
            gameText, _, _, _, _, _, isGameAFK, isGameBusy, guid,
            _, _ = BNGetGameAccountInfo(bnetAccountId)

            gai = {
                gameAccountID = nil,
                clientProgram = client,
                isOnline = isOnline,
                isGameBusy = nil,
                isGameAFK = nil,
                wowProjectID = wowProjectID,
                characterName = characterName,
                realmName = realmName,
                realmDisplayName = realmName, -- TODO different?
                realmID = realmID,
                factionName = faction,
                className = class,
                areaName = zoneName, -- TODO correct?
                characterLevel = level,
                richPresence = zoneName .." - ".. realmName,
                playerGuid = guid,
                isWowMobile = mobile, -- TODO correct?
                canSummon = nil, -- todo
                hasFocus = nil, -- todo
            }
        end

        --local canCoop = CanCooperateWithGameAccount(bnetAccountId)

        obj.BNetInfo = {
            bnetAccountID = bnetAccountId,
            accountName = accountName,
            battleTag = battleTag,
            isFriend = true,
            isBattleTagFriend = true,
            lastOnlineTime = lastOnline,
            isAFK = isAFK,
            isDND = isDND,
            isFavorite = isFavorite,
            appearOffline = nil, -- todo
            customMessage = nil, -- todo
            customMessageTime = nil, -- todo
            note = nil, -- todo
            rafLinkType = nil, -- todo
            gameAccountInfo = gai,
        }
    end
    DEBUG("NewByBNetIndex =", obj.BNetInfo)
    return obj
end


function Xist_Friend:NewByPresenceID(presenceID)
    local index = BNGetFriendIndex(presenceID)
    return self:NewByBNetIndex(index)
end


function Xist_Friend:GetIndex()
    return self.index
end


function Xist_Friend:IsBNetFriend()
    return self.BNetInfo and self.BNetInfo.isFriend or false
end


function Xist_Friend:IsToonFriend()
    return self.ToonInfo and self.ToonInfo.isFriend
end


function Xist_Friend:IsFriend()
    -- true if BNet friend OR if toon friend
    return self:IsBNetFriend() or self:IsToonFriend()
end


function Xist_Friend:GetBattleTag()
    if self.BNetInfo then
        return self.BNetInfo.battleTag
    end
    return nil
end


function Xist_Friend:GetName()
    if self.BNetInfo then
        return self.BNetInfo.accountName
    end
    if self.ToonInfo then
        return self.ToonInfo.name
    end
    return nil
end


function Xist_Friend:GetGUID()
    if self.BNetInfo and self.BNetInfo.gameAccountInfo then
        return self.BNetInfo.gameAccountInfo.playerGuid
    end
    if self.ToonInfo then
        return self.ToonInfo.guid
    end
    return nil
end


function Xist_Friend:IsOnline()
    if self.BNetInfo then
        return self.BNetInfo.gameAccountInfo and self.BNetInfo.gameAccountInfo.isOnline or false
    end
    if self.ToonInfo then
        return self.ToonInfo.connected
    end
    return false
end
