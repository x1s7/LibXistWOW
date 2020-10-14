
local ModuleName = "Xist_UnitTest"
local ModuleVersion = 1

-- If some other addon installed Xist_UnitTest, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UnitTest
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UnitTest
Xist_UnitTest = M


function Xist_UnitTest:New(testModuleName)
    local obj = {
        name = testModuleName,
        tests = {},
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end


function Xist_UnitTest:AddTest(name, test)
    table.insert(self.tests, {
        name = name,
        test = Xist_Util.Bind(self, test),
    })
end


function Xist_UnitTest:GetTests()
    return self.tests
end
