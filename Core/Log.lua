--- @module Xist_Log

local AddonName = ...

Xist_Log = {}

local DEFAULT_NAME_COLOR = "ffffff00"

local settings = {
    debugColor = "ff888888",
    nameColor = DEFAULT_NAME_COLOR,
    nameText = "|c".. DEFAULT_NAME_COLOR .. AddonName .."|r",
    nameTextRaw = AddonName,
    debugTypeColor = "ff008888",
    warningColor = "ffff6666",
    errorColor = "ffff6666",
}


--- Set the addon's name text string for log messages
--- @param text string Name of the addon with text decoration
function Xist_Log.SetNameText(text)
    settings.nameTextRaw = text
    settings.nameText = "|c".. settings.nameColor .. text .."|r"
end


function Xist_Log.SetNameColor(colorHex_ARGB)
    settings.nameColor = colorHex_ARGB
    settings.nameText = "|c".. colorHex_ARGB .. settings.nameTextRaw .."|r"
end


function Xist_Log.SetDebugTypeColor(colorHex_ARGB)
    settings.debugTypeColor = colorHex_ARGB
end


function Xist_Log.MESSAGE(...)
    local msg = "[".. settings.nameText .."] ".. Xist_Util.Args2StringLiteral(...)
    print(msg)
end


function Xist_Log.WARNING(...)
    local msg = "|c".. settings.warningColor .."[".. settings.nameText .."|c".. settings.warningColor .."] "..
            "[WARNING] ".. Xist_Util.Args2StringLiteral(...) .."|r"
    print(msg)
end


function Xist_Log.ERROR(...)
    local msg = "|c".. settings.errorColor .."[".. settings.nameText .."|c".. settings.errorColor .."] "..
            "[ERROR] ".. Xist_Util.Args2StringLiteral(...) .."|r"
    print(msg)
end


function Xist_Log.DEBUG(logId, ...)
    local msg = "|c".. settings.debugColor .."[".. settings.nameText .."|c".. settings.debugColor .."] "..
            "[DEBUG] "
    -- only put the debug log type if it is not nil/blank
    if logId ~= nil and logId ~= "" then
        msg = msg .."[|c".. settings.debugTypeColor .. logId .."|c".. settings.debugColor .."] "
    end
    msg = msg .. Xist_Util.Args2StringLiteral(...) .."|r"
    print(msg)
end


function Xist_Log.DEBUG_DUMP(logId, description, v, depth)
    Xist_Log.DEBUG(logId, description, Xist_Util.PrettyPrintString(v, depth))
end


local function GeneratePrefixedMessage(type, ...)
    local prefix = Xist_Util.Args2StringLiteral(...)
    return function (...)  return Xist_Log[type](prefix, ...) end
end


Xist_Log.Factory = {}

Xist_Log.Factory.MESSAGE = function (...) return GeneratePrefixedMessage("MESSAGE", ...) end
Xist_Log.Factory.WARNING = function (...) return GeneratePrefixedMessage("WARNING", ...) end
Xist_Log.Factory.ERROR = function (...) return GeneratePrefixedMessage("ERROR", ...) end

Xist_Log.Factory.DEBUG = function (...) return GeneratePrefixedMessage("DEBUG", ...) end
Xist_Log.Factory.DEBUG_DUMP = function (...) return GeneratePrefixedMessage("DEBUG_DUMP", ...) end
