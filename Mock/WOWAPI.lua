
Frame = {}

function Frame:New(type, name, parent)
    local obj = {
        type = type,
        name = name,
        parent = parent,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Frame:RegisterEvent(eventName, callback) end
function Frame:SetScript(eventName, callback) end


function CreateFrame(type, name, parent)
    return Frame:New(type, name, parent)
end


function UnitName(type)
    if type == "player" then
        return "Xist"
    end
    return "Xistwannabe"
end
