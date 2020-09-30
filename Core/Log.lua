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


function Xist_Log:FormatText(colorCode, text)
    return "|c".. (self.settings.color[colorCode] or self.settings.color.message) .. text .. "|r"
end


function Xist_Log:GetFormattedName()
    return self:FormatText('name', self.name or "Xist_Log")
end


function Xist_Log:LogMessage(...)
    local msg = ""
    if self.name then
        msg = self:FormatText('message', "[".. self:GetFormattedName() .."] ")
    end
    msg = msg .. self:FormatText('message', Xist_Util.Args2StringLiteral(...))
    print(msg)
end


function Xist_Log:LogWarning(...)
    local msg = ""
    if self.name then
        msg = self:FormatText('warning', "[".. self:GetFormattedName() .."] ")
    end
    msg = msg .. self:FormatText('warning', "[WARNING] ".. Xist_Util.Args2StringLiteral(...))
    print(msg)
end


function Xist_Log:LogError(...)
    local msg = ""
    if self.name then
        msg = self:FormatText('error', "[".. self:GetFormattedName() .."] ")
    end
    msg = msg .. self:FormatText('error', "[ERROR] ".. Xist_Util.Args2StringLiteral(...))
    print(msg)
end


function Xist_Log:LogDebug(...)
    local msg = ""
    if self.name then
        msg = self:FormatText('debug', "[".. self:GetFormattedName() .."] ")
    end
    msg = msg .. self:FormatText('debug', "[DEBUG] ".. Xist_Util.Args2StringLiteral(...))
    print(msg)
end


function Xist_Log:LogDebugDump(description, v, depth)
    self:LogDebug(description, Xist_Util.PrettyPrintString(v, depth))
end
