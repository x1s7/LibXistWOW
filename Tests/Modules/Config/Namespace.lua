
local ModuleName = "Xist_UnitTest__Config_Namespace"
local ModuleVersion = 1

-- If some other addon installed Xist_UnitTest__Config, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UnitTest__Config
local UnitTest, protected = Xist_Module.Install(ModuleName, ModuleVersion, Xist_UnitTest:New(ModuleName))

-- Add this class to the unit test framework
Xist_UnitTestFramework:AddClass(UnitTest)


local ValidUserConfig = {
    buttonClasses = {
        default = {
            backdropClass = 'default',
            fontClass = 'default',
            root = true,
        },
        custom = {
            parent = 'default',
            fontClass = 'fancy',
        },
        reallyCustom = {
            parent = 'custom',
            backdropClass = 'reallyFancy',
        },
        pseudoCustom = {
            parent = 'default',
        },
    },
    widgetSettings = {
        frame = {
            show = true,
            strata = 'DIALOG',
            testHook = 'frame',
        },
        window = {
            parent = 'frame',
            testHook = 'window',
        },
    },
}


UnitTest:OnBeforeTest(function(self)
    self.sandbox.ValidUserConfig = Xist_Config:New(ValidUserConfig)
end)


UnitTest:AddTest('Namespace Resolution', function(self)
    local c = Xist_Config_Namespace:New(self.sandbox.ValidUserConfig, 'buttonClasses')
    assert(c:IsValidClassName('default'))
    assert(c:IsValidClassName('custom'))
    assert(c:IsValidClassName('reallyCustom'))
    assert(c:IsValidClassName('pseudoCustom'))
end)


UnitTest:AddTest('Default Value', function(self)
    local expected = {
        backdropClass = 'default',
        fontClass = 'default',
        root = true,
    }
    local c = Xist_Config_Namespace:New(self.sandbox.ValidUserConfig, 'buttonClasses')
    local actual = c:GetClassData('default')
    local sExpected = Xist_Util.ValueAsString(expected)
    local sActual = Xist_Util.ValueAsString(actual)
    assert(sExpected == sActual, self:ExpectedEqual(sExpected, sActual))
end)


UnitTest:AddTest('Custom Value', function(self)
    local expected = {
        backdropClass = 'default',
        fontClass = 'fancy',
        root = true,
    }
    local c = Xist_Config_Namespace:New(self.sandbox.ValidUserConfig, 'buttonClasses')
    local actual = c:GetClassData('custom')
    local sExpected = Xist_Util.ValueAsString(expected)
    local sActual = Xist_Util.ValueAsString(actual)
    assert(sExpected == sActual, self:ExpectedEqual(sExpected, sActual))
end)


UnitTest:AddTest('Really Custom Value', function(self)
    local expected = {
        backdropClass = 'reallyFancy',
        fontClass = 'fancy',
        root = true,
    }
    local c = Xist_Config_Namespace:New(self.sandbox.ValidUserConfig, 'buttonClasses')
    local actual = c:GetClassData('reallyCustom')
    local sExpected = Xist_Util.ValueAsString(expected)
    local sActual = Xist_Util.ValueAsString(actual)
    assert(sExpected == sActual, self:ExpectedEqual(sExpected, sActual))
end)


UnitTest:AddTest('Pseudo Custom Value', function(self)
    local c = Xist_Config_Namespace:New(self.sandbox.ValidUserConfig, 'buttonClasses')
    local expected = c:GetClassData('default')
    local actual = c:GetClassData('pseudoCustom')
    local sExpected = Xist_Util.ValueAsString(expected)
    local sActual = Xist_Util.ValueAsString(actual)
    assert(sExpected == sActual, self:ExpectedEqual(sExpected, sActual))
end)


UnitTest:AddTest('Missing Class Name Yields Default Value', function(self)
    local c = Xist_Config_Namespace:New(self.sandbox.ValidUserConfig, 'buttonClasses')
    local expected = c:GetClassData('default')
    local actual = c:GetClassData('noSuchClassNameExistsInTheConfig')
    local sExpected = Xist_Util.ValueAsString(expected)
    local sActual = Xist_Util.ValueAsString(actual)
    assert(sExpected == sActual, self:ExpectedEqual(sExpected, sActual))
end)


UnitTest:AddTest('Namespace key is array', function(self)
    local namespace = {'widgetSettings', 'window'}
    local c = Xist_Config_Namespace:New(self.sandbox.ValidUserConfig, namespace)
    local data = c:GetConfigData()
    assert(data.frame == nil)
    assert(data.parent == 'frame')
    assert(data.testHook == 'window')
end)
