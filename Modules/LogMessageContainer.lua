
local ModuleName = "Xist_LogMessageContainer"
local ModuleVersion = 1

-- If some other addon installed Xist_LogMessageContainer, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_LogMessageContainer
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_LogMessageContainer
Xist_LogMessageContainer = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local ERROR = protected.ERROR
local WARNING = protected.WARNING

local width = UIParent:GetWidth() - 40
local height = UIParent:GetHeight() - 40

local HEIGHT_PER_LINE = 15 -- todo compute this based on the text height
local MAX_LINES = 500
local numMessages = 0

local DISPLAY_LINES = math.floor(height / HEIGHT_PER_LINE)
local maxScrollOffset = MAX_LINES - DISPLAY_LINES

local headerHeight = 34
local padding = 4
local scrollbarWidth = 20

local f = Xist_UI:Window(UIParent, width, height)
f:SetFrameStrata("FULLSCREEN_DIALOG")
f:SetPoint("CENTER")
f:Hide() -- don't show this window unless we explicitly ask for it

f.Messages = CreateFrame("ScrollingMessageFrame", nil, f)
f.Messages:SetPoint("TOPLEFT", padding, 0 - headerHeight)
f.Messages:SetPoint("BOTTOMRIGHT", 0 - padding, padding)
f.Messages:SetInsertMode("bottom")
f.Messages:SetMaxLines(MAX_LINES)
f.Messages:SetFading(false)
f.Messages:SetIndentedWordWrap(true)
f.Messages:SetFontObject(ChatFontNormal)
f.Messages:SetJustifyH("LEFT")
f.Messages:Show()

local function ScrollMessageContent(self)
    local offset = FauxScrollFrame_GetOffset(self)
    local tmp = math.max(0, numMessages - DISPLAY_LINES - offset)
    f.Messages:SetScrollOffset(tmp)
    --print("offset=".. offset ..", tmp=".. tmp ..", numMessages=".. numMessages ..", displayLines=".. DISPLAY_LINES)
    FauxScrollFrame_Update(self, numMessages, DISPLAY_LINES, HEIGHT_PER_LINE)
end

f.Scroll = CreateFrame("ScrollFrame", nil, f, "FauxScrollFrameTemplate")
f.Scroll:SetPoint("TOPLEFT", padding, 0 - headerHeight)
f.Scroll:SetPoint("BOTTOMRIGHT", 0 - padding - scrollbarWidth, padding)
f.Scroll:SetScript("OnVerticalScroll",	function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, HEIGHT_PER_LINE, ScrollMessageContent)
end)


local AddMessage_true = f.Messages.AddMessage

function f.Messages:AddMessage(...)

    -- add the message to the frame
    AddMessage_true(self, ...)

    -- only update number of messages if we're displaying fewer than the max lines
    if numMessages <= MAX_LINES then
        numMessages = numMessages + 1
    end

    -- update scrolling position
    f.Scroll:SetVerticalScroll(numMessages * HEIGHT_PER_LINE)
    ScrollMessageContent(f.Scroll)
end

Xist_Log.AssignDebugMessageFrame(f.Messages)

function Xist_LogMessageContainer.Show()
    f:Show()
end
