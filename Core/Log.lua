--- @module Xist_Log

local ModuleVersion = 1

Xist_Log = Xist_Log or {}
-- If some other addon installed Xist_Log, don't do it again
if Xist_Log.version and Xist_Log.version >= ModuleVersion then
    return
end

local DEFAULT_SETTINGS = {
    color = {
        debug = "ff888888",
        debugType = "ff008888",
        error = "ffffcccc",
        message = "ffffffff",
        name = "ffcccc00",
        warning = "ffff8888",
    },
    openBracket = "<",
    closeBracket = ">",
}

local debugMessageFrame
local debugMessageQueue = { "--- begin debug log ---" }


--- Create a new named log object.
--- @param name string Name of the log (displayed in all messages unless empty)
--- @return Xist_Log
function Xist_Log:New(name)
    local obj = {
        name = name, -- possibly nil
        settings = Xist_Util.DeepCopy(DEFAULT_SETTINGS)
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end


--- Assign a specific scrolling message frame to be used for debug messages.
--- @param frame MessageFrame
--- @static
function Xist_Log.AssignDebugMessageFrame(frame)
    debugMessageFrame = frame

    -- if there is a queue of events that need to go there, send them
    for i = 1, #debugMessageQueue do
        debugMessageFrame:AddMessage(debugMessageQueue[i])
    end
    debugMessageQueue = {} -- zero out the queue
end


--- Return a proxy to a specific log's method.
--- @param methodName string Name of a Xist_Log method
--- @return fun
function Xist_Log:Proxy(methodName, ...)
    local instance = self
    return function(...)
        return instance[methodName](instance, ...)
    end
end


function Xist_Log:ColorText(colorCode, text)
    local color = self.settings.color[colorCode] or self.settings.color.message
    return "|c".. color .. (text or "") .. "|r"
end


function Xist_Log:GetFormattedName()
    return self:ColorText('name', self.name or "Xist_Log")
end


--- Write out a log message.
--- @param defaultFrame boolean if true, write this into the default chat frame
--- @param debugFrame boolean if true, write this to the debug chat frame
--- @param colorCode string
--- @param category string|nil
function Xist_Log:Write(defaultFrame, debugFrame, colorCode, category, ...)
    local msg = {}, tmp

    if self.name then
        tmp = self:ColorText(colorCode, self.settings.openBracket) ..
                self:GetFormattedName() ..
                self:ColorText(colorCode, self.settings.closeBracket)
        table.insert(msg, tmp)
    end

    if category and category ~= "" then
        tmp = self:ColorText(colorCode, self.settings.openBracket) ..
                self:ColorText(colorCode, category) ..
                self:ColorText(colorCode, self.settings.closeBracket)
        table.insert(msg, tmp)
    end

    -- colorize every word they gave us -- some may include colorizations that throw off others,
    -- so we just wrap every single word in a color code.
    local words = Xist_Util.Args2StringArrayLiteral(...)
    for i = 1, #words do
        table.insert(msg, self:ColorText(colorCode, words[i]))
    end

    msg = Xist_Util.Join(msg, " ")

    -- if we want to write this to the debug frame, and if there is one, then write there
    if debugFrame then
        if debugMessageFrame then
            debugMessageFrame:AddMessage(msg)
        else
            -- there isn't yet a debugMessageFrame, so save this in the queue for later
            table.insert(debugMessageQueue, msg)
        end
    end

    -- if we want to write this to the default frame, then do so
    if defaultFrame or not debugMessageFrame then
        -- either we explicitly want this in the default frame, OR there is no debug message frame defined,
        -- either way print this to the default frame
        print(msg)
    end
end


function Xist_Log:LogMessage(...)
    return self:Write(true, true, "message", nil, ...)
end


function Xist_Log:LogWarning(...)
    return self:Write(true, true, "warning", "WARNING", ...)
end


function Xist_Log:LogError(...)
    return self:Write(true, true, "error", "ERROR", ...)
end


function Xist_Log:LogDebug(...)
    -- DO NOT write debug output to the default frame by default
    return self:Write(false, true, "debug", "DEBUG", ...)
end


function Xist_Log:LogCategorizedDebug(category, ...)
    local colorizedCategory = self:ColorText("debugType", self.settings.openBracket) ..
            self:ColorText("debugType", category) ..
            self:ColorText("debugType", self.settings.closeBracket)

    -- DO NOT write debug output to the default frame by default
    return self:Write(false, true, "debug", "DEBUG", colorizedCategory, ...)
end


function Xist_Log:LogDebugDump(description, v, depth)
    self:LogDebug(description, Xist_Util.PrettyPrintString(v, depth))
end
