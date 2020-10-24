
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
        Xist__UIParent:Show()
    elseif text == "ui hide" then
        Xist__UIParent:Hide()
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

local function whisperBofx()
    local n = 10
    for i=1, n do
        local msg = 'Hello '.. i ..'/'.. n
        SendChatMessage(msg, 'WHISPER', GetDefaultLanguage('player'), 'Bofx')
    end
    return true
end

local function tableTest()
    local options = {
        { title = 'i', cellClass='white', width=40 },
        { title = 'ii', cellClass='green', width=40 },
        { title = 'iii', cellClass='blue', width=40 },
        { title = 'iiii', cellClass='black', width=40 },
    }
    local win = Xist_UI:Window(nil, 'Table Test')
    local table = Xist_UI:Table(win, options)
    for i=1, 10 do
        table:AddData({ i, i*i, i*i*i, i*i*i*i })
    end
    table:Update()
    win:Show()
    return true
end

local contextMenuOptions = {
    {title = addon:GetName(), color = {1, 1, 0}},
    {text = "Debug Log", callback = Xist_LogMessageContainer.Show},
    {text = "Dump SMF Info", callback = Xist_LogMessageContainer.DebugDump},
    {text = "Run Unit Tests", callback = function() Xist_UnitTestFramework:Run(); return true end},
    {text = "Whisper Bofx", callback = whisperBofx},
    {text = "Table Test", callback = tableTest},
}

local addonButton = Xist_AddonButton:New(addon, contextMenuOptions)

function addonButton:OnLeftClick(isPushed)
    --addon:DEBUG('Clicked addon button', isPushed)
    if not isPushed then
        Xist_LogMessageContainer.Show()
    end
end

addonButton:Init()

addon:Init()
