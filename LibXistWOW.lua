
local AddonName = ...
local AddonVersion = GetAddOnMetadata(AddonName, "Version")

local _ = Xist_Addon:New(AddonName, AddonVersion)
