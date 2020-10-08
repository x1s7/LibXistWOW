
local ModuleName = "Xist_Friend_BattleNet"
local ModuleVersion = 1

-- If some other addon installed Xist_Friend_BattleNet, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Friend_BattleNet, derived from AN INSTANCE OF Xist_Friend
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion, Xist_Friend:New())

--- @class Xist_Friend_BattleNet
Xist_Friend_BattleNet = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local DEBUG_DUMP = protected.DEBUG_DUMP
local ERROR = protected.ERROR
local MESSAGE = protected.MESSAGE
local WARNING = protected.WARNING

local PLAYER_REALM = GetRealmName()
local PLAYER_FACTION = UnitFactionGroup("player")


function Xist_Friend_BattleNet:New()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end


function Xist_Friend_BattleNet:NewByIndex(index)
    local obj = self:New()
    obj.index = index
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


function Xist_Friend_BattleNet:NewByPresenceID(presenceID)
    local index = BNGetFriendIndex(presenceID)
    return self:NewByIndex(index)
end


function Xist_Friend_BattleNet:GetBattleTag()
    if self.BNetInfo then
        return self.BNetInfo.battleTag
    end
    return nil
end


function Xist_Friend_BattleNet:IsFriend()
    if self.BNetInfo then
        return self.BNetInfo.isFriend
    end
    return false
end


function Xist_Friend_BattleNet:GetName()
    if self.BNetInfo then
        return self.BNetInfo.accountName
    end
    return nil
end


--- Get the name of this friend's current toon, if any.
--- @param wantFullName boolean
--- @return string|nil
function Xist_Friend_BattleNet:GetToonName(wantFullName)
    wantFullName = wantFullName or false
    if self.BNetInfo then
        local gai = self.BNetInfo.gameAccountInfo
        -- if this battle.net account is on a realm playing a toon, return the toon's name
        if gai and gai.realmID > 0 and gai.characterName ~= nil then
            if wantFullName then
                return gai.characterName .."-".. gai.realmName
            end
            return gai.characterName
        end
    end
    return nil
end


function Xist_Friend_BattleNet:GetGUID()
    if self.BNetInfo and self.BNetInfo.gameAccountInfo then
        return self.BNetInfo.gameAccountInfo.playerGuid
    end
    return nil
end


function Xist_Friend_BattleNet:IsOnline()
    if self.BNetInfo and self.BNetInfo.gameAccountInfo then
        return self.BNetInfo.gameAccountInfo.isOnline
    end
    return false
end


function Xist_Friend_BattleNet:IsInGame()
    if self.BNetInfo then
        local gai = self.BNetInfo.gameAccountInfo
        if gai and gai.isOnline then
            return gai.realmName == PLAYER_REALM and gai.factionName == PLAYER_FACTION
        end
    end
    return false
end
