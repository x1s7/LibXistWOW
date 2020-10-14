
local ModuleName = "Xist_UnitTestFramework"
local ModuleVersion = 1

-- If some other addon installed Xist_UnitTestFramework, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UnitTestFramework
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UnitTestFramework
Xist_UnitTestFramework = M


Xist_UnitTestFramework.isStatic = true


function Xist_UnitTestFramework:New()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.isStatic = false
    obj.testClasses = {}
    obj.testSummary = {}

    return obj
end


function Xist_UnitTestFramework:GetInstance()
    if self.instance == nil then
        self.instance = self:New()
    end
    return self.instance
end


function Xist_UnitTestFramework:AddClass(class)
    if self.isStatic then
        self = self:GetInstance()
    end
    table.insert(self.testClasses, class)
end


function Xist_UnitTestFramework:Output(...)
    print(Xist_Util.Args2StringLiteral(...))
end


function Xist_UnitTestFramework:OnBeginRun()
    self:Output("Xist_UnitTestFramework beginning tests")
end


function Xist_UnitTestFramework:OnEndRun()
    self:Output("")
    self:Output("Xist_UnitTestFramework tests complete")
    self:Output("")

    for i=1, #self.testSummary do
        local summary = self.testSummary[i]
        self:Output('  '.. summary.ok ..'/'.. summary.total ..' '.. summary.class.name)
    end
end


function Xist_UnitTestFramework:OnBeginTestClass(class)
    self:Output("  >> ".. class.name)

    self.stats = {
        ok = 0,
        fail = 0,
    }
end


function Xist_UnitTestFramework:OnEndTestClass(class)
    local total = self.stats.ok + self.stats.fail

    local extra = ' '.. self.stats.ok ..'/'.. total

    if self.stats.fail > 0 then
        extra = ' << '.. self.stats.fail ..' FAILURES >>'
    end

    self:Output("  << ".. class.name .. extra)

    table.insert(self.testSummary, {
        class = class,
        ok = self.stats.ok,
        fail = self.stats.fail,
        total = total,
    })
end


function Xist_UnitTestFramework:OnBeginTestClassTest(testConfig)
end


function Xist_UnitTestFramework:OnEndTestClassTest(testConfig, isSuccess, errorMessage)
    local statusText
    local suffix = ""
    if isSuccess then
        self.stats.ok = self.stats.ok + 1

        if Xist_CONSOLE_UNIT_TEST then
            statusText = "[ OK ]"
        else
            statusText = "|cff00ff00 OK |r"
        end
    else
        self.stats.fail = self.stats.fail + 1

        if Xist_CONSOLE_UNIT_TEST then
            statusText = "[FAIL]"
        else
            statusText = "|cffff0000FAIL|r"
        end
        suffix = " : ".. errorMessage
    end
    self:Output("    ".. statusText .." ".. testConfig.name .. suffix)
end


function Xist_UnitTestFramework:Run()
    local framework = self or Xist_UnitTestFramework
    if framework.isStatic then
        framework = framework:GetInstance()
    end
    framework:OnBeginRun()
    for _, class in ipairs(framework.testClasses) do
        framework:OnBeginTestClass(class)
        local tests = class:GetTests()
        for _, testConfig in ipairs(tests) do
            framework:OnBeginTestClassTest(testConfig)
            local success, err = pcall(testConfig.test)
            framework:OnEndTestClassTest(testConfig, success, err)
        end
        framework:OnEndTestClass(class)
    end
    framework:OnEndRun()
end
