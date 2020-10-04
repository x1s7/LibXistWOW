
local AddonName = ...
local AddonVersion = GetAddOnMetadata(AddonName, "Version")

local addon = Xist_Addon:New(AddonName, AddonVersion)

addon:AnnounceLoad() -- let's see which version of the lib we have

--- @param text string any arguments to /libxist
local function onSlashCommand(text)
    if text == "debug" then -- /libxist debug
        Xist_LogMessageContainer.Show()
        addon.protected.DEBUG("Showing debug log") -- whether or not debugging is on, let's see that we showed this
    elseif text == "write save data" then
        addon:WriteSaveData()
    end
end

addon:AddSlashCommand("libxist")
addon:SetSlashCommandHandler(onSlashCommand)

addon:OnLoad(function(addonRef)
    -- this just demonstrates save data read/write is working as this value changes every load
    local data = addonRef:GetDataReference()
    addonRef:DEBUG("Loaded with data", data)
    data.toggle = not data.toggle
end)

addon:Init()
