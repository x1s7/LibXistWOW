
local ModuleName = "Xist_UI_MessageFrame"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_MessageFrame, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_MessageFrame
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_MessageFrame
Xist_UI_MessageFrame = M

protected.DebugEnabled = true

local DEBUG = protected.DEBUG


function Xist_UI_MessageFrame:InitializeMessageFrameWidget()
    self.maxMessages = 10
    self.messages = {}
    self.minIndex = 1
    self.maxIndex = 0
    self.linePadding = 2
    self.lineSpacing = 2
    self.totalHeight = 0

    local classConf = self:GetWidgetClassConfig()
    local fontClass = classConf.fontClass or self.widgetClass or 'default'
    local font = self:GetFontByClass(fontClass)

    self.fontHeight = font:GetFontHeight()
end


function Xist_UI_MessageFrame:GetLineHeight()
    return self.lineSpacing + self.fontHeight
end


function Xist_UI_MessageFrame:SetParent(parent)
    self:_SetParent(parent)
    self:SetWidth(parent:GetWidth())
    self:SetHeight(parent:GetHeight())
    self:ClearAllPoints()
    self:SetPoint('BOTTOM')
end


function Xist_UI_MessageFrame:GetTotalHeight()
    return self.totalHeight
end


function Xist_UI_MessageFrame:GetMaxMessages()
    return self.maxMessages
end


function Xist_UI_MessageFrame:SetMaxMessages(limit)

    -- todo REINDEX

    self.maxMessages = limit
end


function Xist_UI_MessageFrame:CreateMessageFontString(text)
    local classConf = self:GetWidgetClassConfig()
    local fontClass = classConf.fontClass or self.widgetClass or 'default'
    local fontString = Xist_UI:FontString(self, fontClass)
    fontString:SetWidth(self:GetWidth())
    fontString:SetText(text)
    return fontString
end


function Xist_UI_MessageFrame:AddMessage(text)
    local fontString = self:CreateMessageFontString(text)
    local height = fontString:GetHeight()

    self.maxIndex = self.maxIndex + 1
    self.messages[self.maxIndex] = {
        text = text,
        fontString = fontString,
        height = height,
    }

    if self.maxIndex - self.minIndex > self.maxMessages then

    end

    self.totalHeight = self.totalHeight + height + self.lineSpacing

    fontString:SetPoint('BOTTOMLEFT', self, self.linePadding, self.lineSpacing)
    fontString:SetWidth(self:GetWidth() - self.linePadding - self.linePadding)

    if self.maxIndex > 1 then
        local lastLabel = self.messages[self.maxIndex-1].fontString
        lastLabel:SetPoint('BOTTOMLEFT', fontString, 'TOPLEFT', 0, self.lineSpacing)
    end

    self:SetHeight(self.totalHeight)
end


function Xist_UI_MessageFrame:DebugDump()
    local m1 = {
        nMsgs = #self.messages,
        tHeight = self.totalHeight,
    }
    DEBUG('MF', m1)
    local m2 = {}
    for i = self.minIndex, self.maxIndex do
        local m = self.messages[i]
        m2[#m2+1] = {w=m.fontString:GetWidth(), h=m.fontString:GetHeight(), H=m.height}
    end
    DEBUG('Messages', unpack(m2))
end
