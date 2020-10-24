
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
    local message = Xist_Util.Args2StringLiteral(...)
    -- if this is not a console unit test (e.g. we're in the game) and if we have a log message container,
    -- then send the output to the log message container.
    if not Xist_CONSOLE_UNIT_TEST and Xist_LogMessageContainer and Xist_LogMessageContainer.AddMessage then
        Xist_LogMessageContainer.AddMessage(message)
    else
        -- When run on the console, or when there is no debug frame in game
        print(message)
    end
end


function Xist_UnitTestFramework:OnBeginRun()
    self:Output("Xist_UnitTestFramework beginning tests")
end


function Xist_UnitTestFramework:OnEndRun()
    self:Output("--------------------------------------------------")
    self:Output("Xist_UnitTestFramework tests complete")
    self:Output("--------------------------------------------------")

    local maxTests = 0
    for i=1, #self.testSummary do
        local summary = self.testSummary[i]
        if summary.total > maxTests then
            maxTests = summary.total
        end
    end

    local digits = Xist_Util.CountDigits(maxTests)
    local totalFail = 0

    for i=1, #self.testSummary do
        local summary = self.testSummary[i]
        local ok = string.format('%0'.. digits ..'d', summary.ok)
        local total = string.format('%0'.. digits ..'d', summary.total)
        local fail = summary.total - summary.ok
        local errorIndicator = (fail == 0) and '  ' or '**'
        totalFail = totalFail + fail
        self:Output('  '.. ok ..' / '.. total ..'  '.. errorIndicator ..'  '.. summary.class.name)
    end

    self:Output("--------------------------------------------------")
    self:Output("Total failures:", totalFail)
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
        for _, unitTest in ipairs(tests) do
            framework:OnBeginTestClassTest(unitTest)
            local success, err = class:PrepareTest()
            if success then
                success, err = pcall(unitTest.test, unitTest)
            end
            framework:OnEndTestClassTest(unitTest, success, err)
        end
        framework:OnEndTestClass(class)
    end
    framework:OnEndRun()
end
