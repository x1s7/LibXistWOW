
local ModuleName = "Xist_AddonButton"
local ModuleVersion = 1

-- If some other addon installed Xist_AddonButton, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_AddonButton
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_AddonButton
Xist_AddonButton = M

protected.DebugEnabled = true

local DEBUG_CAT = protected.DEBUG_CAT
local WARNING = protected.WARNING


--- Create an addon button
--- @param addon Xist_Addon
--- @param options table[] Xist_UI.ContextMenu options
--- @return Xist_AddonButton
function Xist_AddonButton:New(addon, options)

    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.addon = addon
    obj.ContextMenuOptions = options

    return obj
end


function Xist_AddonButton:DEBUG(...)
    DEBUG_CAT(self.addon:GetName(), ...)
end


function Xist_AddonButton:GetDefaultConfig()
    return {
        point = "BOTTOMRIGHT",
        parent = "UIParent",
        relativePoint = "BOTTOMRIGHT",
        xOff = -4,
        yOff = 4,
    }
end


--- Retrieve the button configuration.
function Xist_AddonButton:GetConfig()
    return self.config or self:GetDefaultConfig()
end


function Xist_AddonButton:OnSaveDataRead(data)
    self:DEBUG("OnSaveDataRead", data)

    -- read only the Xist_AddonButton section of the overall addon SaveData
    self.SaveData = Xist_SaveData:New("Xist_AddonButton", data)
    self.config = self.SaveData:Read()

    if self.config then
        self:DEBUG("Read config from save data", self.config)
    else
        self:DEBUG("Config not available in save data, using default")
        self.config = self:GetDefaultConfig()
    end

    -- initialize the button now that we've read the config
    self:InitializeButton()

    -- reset the position based on the save data
    self:SetPosition()
end


function Xist_AddonButton:OnSaveDataWrite()
    local config = self:GetConfig()
    self:DEBUG("Writing config to save data", config)
    self.SaveData:Write(config)
end


function Xist_AddonButton:Init()
    -- Hook into the "addon data has been read" event
    self.addon:RegisterEvent("OnSaveDataRead", Xist_Util.Bind(self, self.OnSaveDataRead))

    -- Hook into the "about to write addon data" event
    self.addon:RegisterEvent("OnSaveDataWrite", Xist_Util.Bind(self, self.OnSaveDataWrite))

    -- create the base button; config is not yet available so this should be real simple
    self.button = self:CreateButton()

    -- create the button's context menu
    self.menu = Xist_UI:ContextMenu(self.button, self.ContextMenuOptions)
    self.menu:Hide()
end


--- Set the position of the AddonButton.
function Xist_AddonButton:SetPosition()
    local config = self:GetConfig()
    self.button:ClearAllPoints()
    self:DEBUG("SetPosition", config)
    self.button:SetPoint(config.point, _G[config.parent], config.relativePoint, config.xOff, config.yOff)
end


local function onClick(button, clickType)
    button.xObj:OnClick(clickType)
end


local function onDragStart(button)
    return button.xObj:StartMoving()
end


local function onDragStop(button)
    return button.xObj:StopMovingOrSizing()
end


--- Create a button to be used as the addon button.
--- Note: This is called BEFORE save data is available.
--- @return Button
function Xist_AddonButton:CreateButton()
    local button = Xist_UI:Button(UIParent)
    button:SetSize(24, 24)
    button:SetText('*')
    return button
end


--- Initialize a button with custom settings.
--- This is called after save data is available, so self.config can be used to customize this.
function Xist_AddonButton:InitializeButton()
    local button = self.button

    -- save a reference back to self
    button.xObj = self

    -- activate left + right clicks
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetScript("OnClick", onClick)

    -- allow moving the button around and saving its position after move
    button:SetMovable(true)
    button:SetClampedToScreen(true)
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", onDragStart)
    button:SetScript("OnDragStop", onDragStop)

    -- Show the button by default
    button:Show()
end


function Xist_AddonButton:Show()
    self.button:Show()
end


function Xist_AddonButton:Hide()
    self.button:Hide()
end


--- Handle the user clicking the AddonButton with the left mouse button.
--- You MUST derive your own class and implement this method if you want left button support.
--- @virtual
Xist_AddonButton.OnLeftClick = protected.NOOP


--- Handle the user clicking the AddonButton with the right mouse button.
--- You MUST derive your own class and implement this method if you want right button support.
--- @virtual
Xist_AddonButton.OnRightClick = protected.NOOP


--- Handle user clicking the AddonButton.
--- @param clickType string The type of click to handle ("LeftButton" or "RightButton")
--- @see https://wowwiki.fandom.com/wiki/API_Button_RegisterForClicks
function Xist_AddonButton:OnClick(clickType)
    --self:DEBUG("OnClick", clickType)
    if clickType == "LeftButton" then
        self:OnLeftClick()
        -- any time left button is clicked, make sure the context menu is hidden
        if self.menu then self.menu:Hide() end
    elseif clickType == "RightButton" then
        self:OnRightClick()
    end
end


function Xist_AddonButton:StartMoving()
    self.button:StartMoving()
end


function Xist_AddonButton:StopMovingOrSizing()
    self.button:StopMovingOrSizing()
    -- get the new screen coordinates of the top/left corner
    local top = self.button:GetTop()
    local left = self.button:GetLeft()
    -- remember the new offset from the top/left corner of the screen
    local config = self:GetConfig()
    config.point = "TOPLEFT"
    config.parent = "UIParent"
    config.relativePoint = "TOPLEFT"
    config.yOff = 0 - (UIParent:GetHeight() - top)
    config.xOff = left
    self.config = config
    -- let's see what the config looks like now
    self:DEBUG("StopMovingOrSizing", {top=top, left=left}, config)
    -- apply the new position
    self:SetPosition()
end
