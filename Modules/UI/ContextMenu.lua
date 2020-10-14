
local ModuleName = "Xist_UI_ContextMenu"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_ContextMenu, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_ContextMenu
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_ContextMenu
Xist_UI_ContextMenu = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG


local function OnContextMenuItemMouseUp(itemFrame, button)
    local hide
    if button == 'LeftButton' then
        if itemFrame.menuItemConf.callback then
            hide = itemFrame.menuItemConf.callback() == true
        end
    elseif button == 'RightButton' then
        hide = true
    end
    if hide then
        itemFrame.menu:Hide()
    end
end


function Xist_UI_ContextMenu:OnContextMenuMouseUp(button)
    if button == 'RightButton' then
        local uiScale = UIParent:GetScale()
        local cursorX, cursorY = GetCursorPosition()

        cursorX = cursorX / uiScale
        cursorY = cursorY / uiScale

        self:ClearAllPoints()

        if self:IsShown() then
            self:Hide()
        else
            self:SetPoint('TOPLEFT', nil, 'BOTTOMLEFT', cursorX, cursorY)
            self:Show()
        end
    end
end


function Xist_UI_ContextMenu:InitializeMenuOptions(options)
    local widgetClassConf = self:GetWidgetClassConfig()
    local items = {}
    local padding = self:GetWidgetSetting('itemPadding', 10)
    local offset = padding
    local maxWidth = 0
    for i, itemConf in ipairs(options) do
        local itemFrame
        local width, height

        if itemConf.title then
            itemFrame = Xist_UI:Label(self, widgetClassConf.titleFontClass)
            itemFrame:SetText(itemConf.title)
        elseif itemConf.text then
            itemFrame = Xist_UI:Button(self)
            itemFrame:SetText(itemConf.text)
            -- there is a special way to check the width/height of button text
            width = itemFrame:GetTextWidth()
            height = itemFrame:GetTextHeight()
        else
            error('Unsupported ContextMenu item config: '.. Xist_Util.Args2StringLiteral(itemConf))
        end

        width = width or itemFrame:GetWidth()
        height = height or itemFrame:GetHeight()

        itemFrame.menu = self
        itemFrame.menuItemConf = itemConf

        itemFrame:SetScript('OnMouseUp', OnContextMenuItemMouseUp)

        itemFrame:ClearAllPoints()

        DEBUG("InitializeMenuItems ["..i.."]", {width=width, height=height})

        itemFrame:SetPoint('TOPLEFT', padding, -offset)

        if width > maxWidth then
            maxWidth = width
        end

        -- AFTER checking the width then pin the right side
        itemFrame:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -padding, -offset-height)

        items[#items+1] = itemFrame
        offset = offset + height + padding
    end

    self.items = items

    width = maxWidth + padding + padding
    height = offset

    self:SetSize(width, height)
end


function Xist_UI_ContextMenu:InitializeContextMenuWidget(options)
    self:InitializeMenuOptions(options)
    local menu = self
    self:GetParent():HookScript('OnMouseUp', function(_, button) menu:OnContextMenuMouseUp(button) end)
end
