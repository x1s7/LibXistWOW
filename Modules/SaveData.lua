
local ModuleName = "Xist_SaveData"
local ModuleVersion = 1

-- If some other addon installed Xist_SaveData, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_SaveData
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_SaveData
Xist_SaveData = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG


--- Create new SaveData object.
--- @param name string Name of the variable within the scope
--- @param scope table _G or some reduced scope
--- @return Xist_SaveData
function Xist_SaveData:New(name, scope)
    local obj = {
        name = name,
        scope = scope or _G, -- global scope if not otherwise specified
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end


--- Get a piece of meta data.
--- This is only valid after a call to Read()
--- @param key string Any valid meta data key ("time", "writes", "data", "age")
function Xist_SaveData:GetMetaData(key)
    if key == "age" then
        -- "age" is meta-meta data, computed every time you ask for it
        local t = self:GetMetaData("time")
        -- @see https://wow.gamepedia.com/API_time
        return t and (time() - t) or nil
    else
        -- all other keys are static meta data
        return self.metaData and self.metaData[key] or nil
    end
end


--- Get the user data.
--- This is only valid after a call to Read()
--- @return any
function Xist_SaveData:GetData()
    return self:GetMetaData('data')
end


--- Create meta data for this data.
--- If this save already contains meta data, keep it.
--- @param data any
--- @return table
function Xist_SaveData:CreateMetaData(data)
    -- copy current metaData, or create a new one
    local metaData = Xist_Util.DeepCopy(self.metaData) or {
        time = 0,
        writes = 0,
    }
    -- place a copy of the data into the new metaData
    metaData.data = Xist_Util.DeepCopy(data)
    return metaData
end


--- Read and return saved data.
--- Discards any current cache/meta data if you call this multiple times.
--- @return any
function Xist_SaveData:Read()
    local metaData
    local valid = false
    -- look for saved data in the scope
    if self.scope then
        metaData = Xist_Util.DeepCopy(self.scope[self.name])
        if metaData then
            if metaData.time then -- DO NOT check metaData.data, it could legitimately be nil
                valid = true
                DEBUG("Read: `".. self.name .."' =", metaData)
            else
                DEBUG("Read: `".. self.name .."' in scope but is invalid meta data")
            end
        else
            DEBUG("Read: `".. self.name .."' not found in scope")
        end
    else
        DEBUG("Read: scope is nil")
    end
    -- if there is no valid save data, generate a default
    if not valid then
        DEBUG("Read: `".. self.name .."' returning nil data")
        metaData = self:CreateMetaData(nil)
    end
    self.metaData = metaData
    return metaData.data -- possibly nil
end


--- Read and return saved data only if we have not already.
--- @return any
function Xist_SaveData:ReadOnce()
    if not self.metaData then
        return self:Read()
    end
    return self.metaData.data -- possibly nil
end


--- Write data to the saved data.
--- @param data any
function Xist_SaveData:Write(data)
    if self.scope then
        local metaData = self:CreateMetaData(data)
        -- @see https://wow.gamepedia.com/API_time
        metaData.time = time() -- mark the current time of the write
        metaData.writes = metaData.writes + 1 -- increment the number of writes
        self.metaData = metaData -- store the new metaData locally
        self.scope[self.name] = Xist_Util.DeepCopy(metaData) -- write a copy of the metaData to the save scope
        DEBUG("Write: `".. self.name .."' wrote", metaData)
    else
        -- throw an exception
        error("Attempt to write saved data to a nil scope")
    end
end
