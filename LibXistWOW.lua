
local AddonName = ...
local AddonVersion = GetAddOnMetadata(AddonName, "Version")

local addon = Xist_Addon:New(AddonName, AddonVersion)

addon:AnnounceLoad() -- let's see which version of the lib we have

addon:Init()
