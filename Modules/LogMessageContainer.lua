
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
smf:SetMaxMessages(128)

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
