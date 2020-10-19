
local ModuleName = "Xist_LogMessageContainer"
local ModuleVersion = 1

-- If some other addon installed Xist_LogMessageContainer, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_LogMessageContainer
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_LogMessageContainer
Xist_LogMessageContainer = M

--protected.DebugEnabled = true


local win = Xist_UI:Window(nil, 'DEBUG Messages')
win:SetSize(800, 600)
win:Hide() -- do not show by default

local smf = Xist_UI:ScrollingMessageFrame(win)
smf:SetMaxMessages(256)

local AddMessage = smf.AddMessage -- the actual Xist_UI_Widget_ScrollingMessageFrame.AddMessage
local lock = false
local queue = {}

--- Custom locking AddMessage.
--- The process of adding a message to a scrollingMessageFrame might spawn debug or other log messages.
--- That would create an infinite loop if we didn't lock here, so we lock.
--- @param text string
function smf:AddMessage(text)
    if lock then
        queue[1+#queue] = text
    else
        lock = true
        AddMessage(smf, text)
        for i=1, #queue do
            AddMessage(smf, queue[i])
        end
        queue = {}
        lock = false
    end
end

Xist_Log.AssignDebugMessageFrame(smf)


function Xist_LogMessageContainer.DebugDump()
    smf:DebugDump()
    return true
end

--- Show the debug log frame.
function Xist_LogMessageContainer.Show()
    win:Show()
    return true
end

--- Hide the debug log frame.
function Xist_LogMessageContainer.Hide()
    win:Hide()
    return true
end
