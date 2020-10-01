
local ModuleName = "Xist_Version"
local ModuleVersion = 1

-- If some other addon installed Xist_Version, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Version
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_Version
Xist_Version = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local ERROR = protected.ERROR
local WARNING = protected.WARNING


--- Determine if two Xist_Version are equal
--- @param a Xist_Version
--- @param b Xist_Version
--- @return boolean
local function isVersionEqual(a, b)
    return  a.major == b.major and
            a.minor == b.minor and
            a.patch == b.patch and
            a.tag   == b.tag
end


--- Determine if Xist_Version a < Xist_Version b
--- @param a Xist_Version
--- @param b Xist_Version
--- @return boolean
local function isVersionLess(a, b)
    if a.major < b.major then
        return true
    elseif a.major == b.major then
        -- same major version, check minor
        if a.minor < b.minor then
            return true
        elseif a.minor == b.minor then
            -- same major.minor version, check patch
            if a.patch < b.patch then
                return true
            elseif a.patch == b.patch then
                -- same major.minor.patch version, check tag
                if a.tag == b.tag then
                    -- the tags are equal (possibly nil)
                    return false
                end
                -- here we will compare tags alphabetically so this can be used to sort
                return (a.tag or '') < (b.tag or '')
            end
        end
    end
    return false
end


--- Determine if Xist_Version a <= Xist_Version b
--- @param a Xist_Version
--- @param b Xist_Version
--- @return boolean
local function isVersionLessOrEqual(a, b)
    return isVersionEqual(a, b) or isVersionLess(a, b)
end


--- Get string representation of Xist_Version
--- @param self Xist_Version
--- @return string
local function toString(self)
    local str = (self.major or 0) ..".".. (self.minor or 0) ..".".. (self.patch or 0)
    if self.tag ~= nil and self.tag ~= "" then
        str = str .."-".. self.tag
    end
    return str
end


local META = {
    __eq = isVersionEqual,
    __index = Xist_Version,
    __le = isVersionLessOrEqual,
    __lt = isVersionLess,
    __tostring = toString,
}


--- Create a new version with explicit number
--- @param major number|nil default 0
--- @param minor number|nil default 0
--- @param patch number|nil default 0
--- @param tag string|nil default nil
--- @return Xist_Version
function Xist_Version:NewExplicit(major, minor, patch, tag)
    local obj = {
        major = major or 0,
        minor = minor or 0,
        patch = patch or 0,
        tag = tag, -- possibly nil
    }
    setmetatable(obj, META)
    return obj
end


--- Parse a version string into a Xist_Version
--- @param versionStr string format "major.minor.patch-tag"
--- @param silent boolean if true no warnings will be printed
--- @return Xist_Version
function Xist_Version:Parse(versionStr, silent)
    if type(versionStr) ~= "string" then
        if not silent then
            WARNING("Attempt to parse a version string from a ".. type(versionStr) .." variable")
        end
        return nil
    end

    local s = versionStr
    local minor, patch, tag
    local _, j, major = string.find(s, "(%d+)")
    DEBUG("Parse version `".. versionStr .."' [1]", {j=j, major=major})

    if major == nil then
        -- we didn't find even a major version number in this string
        if not silent then
            WARNING("Malformed version string `".. versionStr .."', no version info")
        end
    else
        s = strsub(s, j)
        _, j, minor = string.find(s, "\.(%d+)")
        DEBUG("Parse version `".. versionStr .."' [2]", {j=j, major=major, minor=minor})

        if minor ~= nil then
            s = strsub(s, j)
            _, j, patch = string.find(s, "\.(%d+)")
            DEBUG("Parse version `".. versionStr .."' [3]", {j=j, major=major, minor=minor, patch=patch})

            if patch ~= nil then
                s = strsub(s, j)
                _, j, tag = string.find(s, "\-(.+)")
                DEBUG("Parse version `".. versionStr .."' [4]", {j=j, major=major, minor=minor, patch=patch, tag=tag})
            end
        end
    end
    return Xist_Version:NewExplicit(major, minor, patch, tag)
end


--- Create a new Xist_Version from an unknown source
--- @param version Xist_Version|string|number|nil
--- @return Xist_Version
function Xist_Version:New(version)
    local t = version and type(version) or nil
    if t == "number" then
        -- a major version number was specified, nothing else
        return Xist_Version:NewExplicit(version)
    elseif t == "string" then
        -- a string was specified, could be any format
        return Xist_Version:Parse(version)
    elseif t == 'table' then
        -- a table was specified, if it looks like a Xist_Version then copy it
        if version.major ~= nil and version.minor ~= nil then
            return Xist_Version:NewExplicit(version.major, version.minor, version.patch, version.tag)
        end
        -- throw exception, invalid table specified
        error("Attempt to instantiate a version from a non-version table")
    elseif version == nil then
        -- no version specified, return new empty 0.0.0
        return Xist_Version:NewExplicit()
    end
    -- exception, we don't know how to turn this into a version
    error("Invalid version type: ".. t)
end
