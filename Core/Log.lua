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

    -- a reference to self for proxy calls
    obj.instance = obj

    return obj
end


--- Return a proxy to a specific log's method.
--- @param methodName string Name of a Xist_Log method
--- @return fun
function Xist_Log:Proxy(methodName, ...)
    local instance = self.instance
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
--- @param colorCode string
--- @param category string|nil
function Xist_Log:Write(colorCode, category, ...)
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

    table.insert(msg, self:ColorText(colorCode, Xist_Util.Args2StringLiteral(...)))

    print(Xist_Util.Join(msg, " "))
end


function Xist_Log:LogMessage(...)
    return self:Write("message", nil, ...)
end


function Xist_Log:LogWarning(...)
    return self:Write("warning", "WARNING", ...)
end


function Xist_Log:LogError(...)
    return self:Write("error", "ERROR", ...)
end


function Xist_Log:LogDebug(...)
    return self:Write("debug", "DEBUG", ...)
end


function Xist_Log:LogDebugDump(description, v, depth)
    self:LogDebug(description, Xist_Util.PrettyPrintString(v, depth))
end
