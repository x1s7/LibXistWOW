--- @module Xist_Util

local ModuleVersion = 1

Xist_Util = Xist_Util or {}

-- If some other addon installed Xist_Util, don't do it again
-- Here we cannot use Xist_Module.NeedsUpgrade since this lib is required by that one.
if Xist_Util.version and Xist_Util.version >= ModuleVersion then
    return
end

-- Initialize Xist_Util

Xist_Util.version = ModuleVersion


--- Join multiple arguments into a single list.
--- @return table[]
function Xist_Util.ToList(...)
    local result = {}
    local n = select('#', ...)
    for i = 1, n do
        result[i] = select(i, ...)
    end
    return result
end


--- Join multiple words together using delimiter.
--- @param words table[]
--- @param delimiter string
--- @return string
function Xist_Util.Join(words, delimiter)
    local str = ""
    for i=1, #words do
        if i > 1 then
            str = str .. delimiter
        end
        str = str .. words[i]
    end
    return str
end


--- Split a string at every regexp match.
--- @param str string
--- @param regexp string
--- @return table[] list of strings
function Xist_Util.Split(str, regexp)
    local parts = {}
    for part in str:gmatch(regexp) do
        table.insert(parts, part)
    end
    return parts
end


--- Split a string into 2 parts on a delimiter.
--- @param str string
--- @param delimiter string
--- @return string, string
function Xist_Util.Split2(str, delimiter)
    -- cannot split nil or on a nil/empty delimiter
    if str == nil or delimiter == nil or delimiter == "" then
        return str
    end
    local i = string.find(str, delimiter)
    if i == nil then
        -- there is no delimiter
        return str
    end
    local w1 = string.sub(str, 1, i - 1)
    local w2 = string.sub(str, i + 1)
    return w1, w2
end


--- Copy a slice of a table.
--- @param arr table[]
--- @param off number starting offset
--- @param len number length of slice to copy
--- @return table[]
function Xist_Util.Slice(arr, off, len)
    local result = {}
    -- if offset is negative, then it's from the end of the array
    if off < 0 then off = #arr + off end
    -- if offset is greater than array length, return empty set
    if off > #arr then return {} end
    -- max length is the length from offset to end of array
    len = math.min(len, #arr - off + 1)
    -- copy relevant elements
    for i=off, len do
        table.insert(result, arr[i])
    end
    return result
end


--- Merge subsequent tables into the first table.
--- Data from later tables overwrites data from earlier tables.
--- @usage local m = XT_Util.MergeInto({a=1}, {a=2}, {b=3}) -- result: m == {a=2, b=3}
--- @param table1 table first table
--- @param table2 table second table
--- @param tableN table Nth table
--- @return table the first table with other tables merged into it
function Xist_Util.MergeInto(...)
    local r = select(1, ...) or {}
    for i = 2, select("#", ...) do
        local t = select(i, ...)
        if t ~= nil then
            for k, v in pairs(t) do
                r[k] = v
            end
        end
    end
    return r
end


--- Merge multiple tables together.
--- Data from later tables overwrites data from earlier tables.
--- @usage local m = XT_Util.Merge({a=1}, {a=2}, {b=3}) -- result: m == {a=2, b=3}
--- @param table1 table first table
--- @param table2 table second table
--- @param tableN table Nth table
--- @return table a new table resulting from merger of arguments
function Xist_Util.Merge(...)
    local r = {}
    for i = 1, select("#", ...) do
        local t = select(i, ...)
        if t ~= nil then
            for k, v in pairs(t) do
                r[k] = v
            end
        end
    end
    return r
end


--- Sort assoc table keys for iteration.
--- The default sort function is ascending alphabetical.
--- @overload fun(tbl:table):fun():string, any
--- @overload fun(tbl:table, sortFn:fun(a:string,b:string):boolean):fun():string, any
--- @usage for k,v in PairsByKeys(table) do something(k,v) end
--- @param tbl table<string, any>|any[] the table over whose keys to iterate
--- @param sortFn fun(a:string,b:string):boolean sort methodology
--- @return fun():string, any
function Xist_Util.PairsByKeys(tbl, sortFn)
    local a = {}
    for n in pairs(tbl) do table.insert(a, n) end
    table.sort(a, sortFn)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], tbl[a[i]]
        end
    end
    return iter
end


--- Return the string representation of v.
--- If v is a string, it will be quoted.
--- All other types are converted to a string representation.
--- @param v any a variable of any type
--- @param depth number default=1 the maximum depth of table traversal (if 0, INFINITE depth)
--- @param currentLevel number INTERNAL USE ONLY: the current level of depth traversal
--- @return string
function Xist_Util.ValueAsString(v, depth, currentLevel)
    if depth == nil then depth = 0 end
    if currentLevel == nil then currentLevel = 1 end
    local t = type(v)
    if t == "number" then
        return tostring(v)
    elseif t == "boolean" then
        if v then return "true" end
        return "false"
    elseif t == "nil" then
        return "nil"
    elseif t == "table" then
        -- if we're limited on depth and we've reached the limit,
        -- just say there is more data here and return
        if depth > 0 and currentLevel > depth then
            return "{...}"
        end
        -- we want to traverse this depth
        local vv = ""
        for sk, sv in Xist_Util.PairsByKeys(v) do
            if vv ~= "" then
                vv = vv .. ", "
            end
            vv = vv .. string.format("%s=%s", sk, Xist_Util.ValueAsString(sv, depth, 1+currentLevel))
        end
        return "{" .. vv .. "}"
    elseif t == "string" then
        return string.format("%q", v) -- it's already a string
    elseif t == "function" then
        return "func()"
    end
    return "[UNKNOWN_TYPE:" .. t .. "]"
end


--- Return the literal string representation of v.
--- If v is a string it will be returned unquoted.
--- All other types are converted to string representations.
--- @param v any a variable of any type
--- @param depth number default=1 the maximum depth of table traversal (if 0, INFINITE depth)
--- @return string
function Xist_Util.ValueAsStringLiteral(v, depth)
    if type(v) == "string" then
        return v
    end
    return Xist_Util.ValueAsString(v, depth)
end


--- Return a nicely formatted multi-line string.
--- @param data any a variable of any type
--- @param depth number default=1 the maximum depth of table traversal (if 0, INFINITE depth)
--- @param prefix string default="" the prefix before each line
--- @param currentLevel number INTERNAL USE ONLY the current depth level
--- @return string
function Xist_Util.PrettyPrintString(data, depth, prefix, currentLevel)
    if prefix == nil then prefix = "" end
    if depth == nil then depth = 1 end -- unless explicitly stated otherwise, max depth 1 level
    if currentLevel == nil then currentLevel = 1 end
    local t = type(data)
    local str = ""
    local numKeys = 0
    if t == "table" then
        for k, v in Xist_Util.PairsByKeys(data) do
            numKeys = numKeys + 1
            local vPretty
            if type(v) == "table" then
                if depth > 0 and currentLevel > depth then
                    vPretty = "{...}"
                else
                    vPretty = Xist_Util.PrettyPrintString(v, depth, prefix .. "  ", currentLevel + 1)
                end
            else
                vPretty =Xist_Util.ValueAsString(v)
            end
            str = str .. prefix .. "  " .. k .. " = " .. vPretty .. ",\n"
        end
        if numKeys == 0 then
            str = "{}"
        else
            str = "{\n" ..          -- line 1
                    str ..          -- 1..N lines
                    prefix .. "}"   -- last line (no trailing newline)
        end
    else
        str = Xist_Util.ValueAsString(data, 1)
    end
    return prefix .. str
end


--- Return a literal string translation of all arguments.
--- @return string
function Xist_Util.Args2StringLiteral(...)
    local n = select("#", ...)
    if n == 0 then return "" end
    local str = Xist_Util.ValueAsStringLiteral(select(1, ...), 1) -- max depth 1
    for i = 2, n do
        str = str .. " " .. Xist_Util.ValueAsStringLiteral(select(i, ...), 1) -- max depth 1
    end
    return str
end


--- Return an array of literal string translations of all arguments.
--- @return table[]
function Xist_Util.Args2StringArrayLiteral(...)
    local r = {}
    local n = select("#", ...)
    for i = 1, n do
        r[i] = Xist_Util.ValueAsStringLiteral(select(i, ...), 1) -- max depth 1
    end
    return r
end


--- Make a deep copy of a table.
--- @param orig table the original table
--- @return table a copy of orig
function Xist_Util.DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Xist_Util.DeepCopy(orig_key)] = Xist_Util.DeepCopy(orig_value)
        end
        setmetatable(copy, Xist_Util.DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


--- Split a fully qualified toon name.
--- @param name string Name in the format "toon-realm"
--- @return string, string|nil "toon", "realm"
function Xist_Util.SplitToonFullName(name)
    return Xist_Util.Split2(name, "-")
end


--- Split a BattleTag into the display name and the unique id.
--- @param battleTag string Name like "Name#1234"
--- @return string, string "Name", "1234"
function Xist_Util.SplitBattleTag(battleTag)
    return Xist_Util.Split2(battleTag, "#")
end


--- Bind a callback method to an object.
--- @param obj table
--- @param method fun(...)
--- @return fun(...)
function Xist_Util.Bind(obj, method)
    return function (...)
        return method(obj, ...)
    end
end
