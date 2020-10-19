
local AddonName = ...
local AddonVersion = GetAddOnMetadata(AddonName, "Version")

local addon = Xist_Addon:New(AddonName, AddonVersion)

addon:AnnounceLoad() -- let's see which version of the lib we have

--- @param text string any arguments to /libxist
local function onSlashCommand(text)
    if text == "debug" then -- /libxist debug
        Xist_LogMessageContainer.Show()
        addon.protected.DEBUG("Showing debug log") -- whether or not debugging is on, let's see that we showed this
    elseif text == "nodebug" then
        Xist_LogMessageContainer.Hide()
        addon.protected.DEBUG("Hiding debug log") -- whether or not debugging is on, let's see that we showed this
    elseif text == "test" then
        Xist_UnitTestFramework:Run()
    elseif text == "ui show" then
        Xist_UI.UIParent:Show()
    elseif text == "ui hide" then
        Xist_UI.UIParent:Hide()
    elseif text == "write save data" then
        addon:WriteSaveData()
    else
        addon:ERROR("Invalid command `/libxist ".. text .."'")
    end
end

addon:AddSlashCommand("libxist")
addon:SetSlashCommandHandler(onSlashCommand)

addon:OnLoad(function(addonRef)
    -- this just demonstrates save data read/write is working as this value changes every load
    local data = addonRef:GetDataReference()
    data.toggle = not data.toggle
end)

local function testUI()
    local win = Xist_UI:Window(nil, 'TEST UI Window')
    win:Show()
    return true
end

local contextMenuOptions = {
    {title = addon:GetName(), color = {1, 1, 0}},
    {text = "Debug Log", callback = Xist_LogMessageContainer.Show},
    {text = "Dump SMF Info", callback = Xist_LogMessageContainer.DebugDump},
    {text = "Run Unit Tests", callback = function() Xist_UnitTestFramework:Run(); return true end},
    {text = "UI/Window", callback = testUI},
}

local addonButton = Xist_AddonButton:New(addon, contextMenuOptions)

function addonButton:OnLeftClick()
    addon:DEBUG('Clicked addon button')
    Xist_LogMessageContainer.Show()
end

addonButton:Init()

addon:Init()
