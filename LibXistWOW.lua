
local AddonName = ...
local AddonVersion = GetAddOnMetadata(AddonName, "Version")

local addon = Xist_Addon:New(AddonName, AddonVersion)

addon:AnnounceLoad() -- let's see which version of the lib we have

--- @param text string any arguments to /libxist
local function onSlashCommand(text)
    if text == "debug" then -- /libxist debug
        Xist_LogMessageContainer.Show()
        addon.private.DEBUG("Showing debug log") -- whether or not debugging is on, let's see that we showed this
    end
end

addon:AddSlashCommand("libxist")
addon:SetSlashCommandHandler(onSlashCommand)

addon:Init()
