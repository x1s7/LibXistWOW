
local ModuleName = "Xist_UnitTest"
local ModuleVersion = 1

-- If some other addon installed Xist_UnitTest, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UnitTest
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UnitTest
Xist_UnitTest = M


--- Create a new UnitTest with a given name.
--- @param testModuleName string
--- @return Xist_UnitTest
function Xist_UnitTest:New(testModuleName)
    local obj = {
        name = testModuleName,
        tests = {},
        sandbox = {},
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end


--- Add a named test callback.
--- @param name string
--- @param test fun(self)
function Xist_UnitTest:AddTest(name, test)
    table.insert(self.tests, {
        name = name,
        test = Xist_Util.Bind(self, test),
    })
end


--- Get a list of this class's tests.
--- @return table[]
function Xist_UnitTest:GetTests()
    return self.tests
end


function Xist_UnitTest:OnBeforeTest(callback)
    self.onBeforeTestHandler = callback
end


function Xist_UnitTest:PrepareTest()
    self.sandbox = {}
    if self.onBeforeTestHandler then
        return pcall(self.onBeforeTestHandler, self)
    end
    return true
end


function Xist_UnitTest:StringValuesAreEqual(first, second)
    return Xist_Util.ValueAsString(first) == Xist_Util.ValueAsString(second)
end


--- Produce an exception description `Expected expected == actual'
--- @param expected any
--- @param actual any
--- @return string
function Xist_UnitTest:ExpectedEqual(expected, actual)
    local expectedStr = Xist_Util.ValueAsString(expected)
    local actualStr = Xist_Util.ValueAsString(actual)
    return 'Expected '.. expectedStr ..' == '.. actualStr
end


--- Produce an exception description `Expected true == actual'
--- @param actual any
--- @return string
function Xist_UnitTest:ExpectedTrue(actual)
    local actualStr = Xist_Util.ValueAsString(actual)
    return 'Expected true == '.. actualStr
end


--- Produce an exception description `Expected false == actual'
--- @param actual any
--- @return string
function Xist_UnitTest:ExpectedFalse(actual)
    local actualStr = Xist_Util.ValueAsString(actual)
    return 'Expected false == '.. actualStr
end


--- Produce an exception description `Expected lesser < greater'
--- @param lesser any
--- @param greater any
--- @return string
function Xist_UnitTest:ExpectedLessThan(lesser, greater)
    local lesserStr = Xist_Util.ValueAsString(lesser)
    local greaterStr = Xist_Util.ValueAsString(greater)
    return 'Expected '.. lesserStr ..' < '.. greaterStr
end


--- Produce an exception description `Expected lesser <= greaterOrEqual'
--- @param lesser any
--- @param greaterOrEqual any
--- @return string
function Xist_UnitTest:ExpectedLessOrEqual(lesser, greaterOrEqual)
    local lesserStr = Xist_Util.ValueAsString(lesser)
    local greaterStr = Xist_Util.ValueAsString(greaterOrEqual)
    return 'Expected '.. lesserStr ..' <= '.. greaterStr
end


--- Produce an exception description `Expected nil == actual'
--- @param actual any
--- @return string
function Xist_UnitTest:ExpectedNil(actual)
    local actualStr = Xist_Util.ValueAsString(actual)
    return 'Expected nil == '.. actualStr
end
