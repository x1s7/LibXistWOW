--- @see https://github.com/Gethe/wow-ui-source/blob/classic/FrameXML/ObjectAPI/Item.lua

local ModuleName = "Xist_Item"
local ModuleVersion = 1

-- If some other addon installed Xist_Item, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Item
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_Item
Xist_Item = M

protected.DebugEnabled = true


--- @param itemQuery number|string ItemID or ItemLink
--- @param onLoadCallback fun(item:Xist_Item)|nil
local function LoadItem(xItem, itemQuery, onLoadCallback)
    xItem.query = itemQuery
    xItem.isLoaded = false

    local t = type(itemQuery)
    if t == 'number' then
        xItem.itemID = itemQuery
        xItem.item = Item:CreateFromItemID(itemQuery)
    elseif t == 'string' then
        xItem.itemLink = itemQuery
        xItem.item = Item:CreateFromItemLink(itemQuery)
        -- @see https://wow.gamepedia.com/ItemLink
        local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(itemQuery, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
        xItem.itemID = tonumber(Id)
        xItem.itemEnchant = tonumber(Enchant)
    else
        error('Cannot create an item using a '.. t ..' query')
    end

    xItem.item:ContinueOnItemLoad(function()
        xItem.isLoaded = true

        xItem.itemID = xItem.item:GetItemID()
        xItem.itemLink = xItem.item:GetItemLink()
        xItem.itemName = xItem.item:GetItemName()
        xItem.itemGUID = xItem.item:GetItemGUID()

        local itemName, itemLink, quality, level, minLevel, type, subType, maxStackCount,
        equipLoc, icon, sellPrice, classID, subClassID, bindType, expacID, setID,
        isCraftingReagent = GetItemInfo(xItem.itemLink)

        xItem.itemQuality = quality
        xItem.itemLevel = level
        xItem.itemMinLevel = minLevel
        xItem.itemType = type
        xItem.itemSubType = subType
        xItem.itemMaxStackCount = maxStackCount
        xItem.itemEquipLoc = equipLoc
        xItem.itemIcon = icon
        xItem.itemSellPrice = sellPrice
        xItem.itemClassID = classID
        xItem.itemSubClassID = subClassID
        xItem.itemBindType = bindType
        xItem.itemExpacID = expacID
        xItem.itemSetID = setID
        xItem.itemIsCraftingReagent = isCraftingReagent

        -- If there is an on load callback, execute it
        if onLoadCallback then
            onLoadCallback(xItem)
        end
    end)
end


--- @param itemQuery number|string ItemID or ItemLink
--- @param onLoadCallback fun(item:Xist_Item)|nil Callback to execute after item data is loaded
--- @return Xist_Item
function Xist_Item:New(itemQuery, onLoadCallback)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    if itemQuery then
        LoadItem(obj, itemQuery, onLoadCallback)
    end

    return obj
end


--- @param str string
--- @return table[] List of ItemLink strings found in str
function Xist_Item:ExtractLinksFromString(str)
    local links = {}
    for capture in string.gmatch(str, "|%x+|Hitem:.-|h.-|h|r") do
        links[1+#links] = capture
    end
    return links
end


--- @return boolean
function Xist_Item:IsLoaded()
    return self.isLoaded
end


--- @return number|nil
function Xist_Item:GetID                () if self.isLoaded then return self.itemID                 end return nil end
--- @return string|nil
function Xist_Item:GetLink              () if self.isLoaded then return self.itemLink               end return nil end
--- @return string|nil
function Xist_Item:GetName              () if self.isLoaded then return self.itemName               end return nil end
--- @return string|nil
function Xist_Item:GetGUID              () if self.isLoaded then return self.itemGUID               end return nil end
--- @return number|nil
function Xist_Item:GetQuality           () if self.isLoaded then return self.itemQuality            end return nil end
--- @return number|nil
function Xist_Item:GetLevel             () if self.isLoaded then return self.itemLevel              end return nil end
--- @return number|nil
function Xist_Item:GetMinLevel          () if self.isLoaded then return self.itemMinLevel           end return nil end
--- @return number|nil
function Xist_Item:GetType              () if self.isLoaded then return self.itemType               end return nil end
--- @return number|nil
function Xist_Item:GetSubType           () if self.isLoaded then return self.itemSubType            end return nil end
--- @return number|nil
function Xist_Item:GetMaxStackCount     () if self.isLoaded then return self.itemMaxStackCount      end return nil end
--- @return number|nil
function Xist_Item:GetEquipLoc          () if self.isLoaded then return self.itemEquipLoc           end return nil end
--- @return number|nil
function Xist_Item:GetIcon              () if self.isLoaded then return self.itemIcon               end return nil end
--- @return number|nil
function Xist_Item:GetSellPrice         () if self.isLoaded then return self.itemSellPrice          end return nil end
--- @return number|nil
function Xist_Item:GetClassID           () if self.isLoaded then return self.itemClassID            end return nil end
--- @return number|nil
function Xist_Item:GetSubClassID        () if self.isLoaded then return self.itemSubClassID         end return nil end
--- @return number|nil
function Xist_Item:GetBindType          () if self.isLoaded then return self.itemBindType           end return nil end
--- @return number|nil
function Xist_Item:GetExpacID           () if self.isLoaded then return self.itemExpacID            end return nil end
--- @return number|nil
function Xist_Item:GetSetID             () if self.isLoaded then return self.itemSetID              end return nil end
--- @return boolean|nil
function Xist_Item:GetIsCraftingReagent () if self.isLoaded then return self.itemIsCraftingReagent  end return nil end
