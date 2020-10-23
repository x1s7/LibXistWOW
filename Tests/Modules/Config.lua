
local ModuleName = "Xist_UnitTest__Config"
local ModuleVersion = 1

-- If some other addon installed Xist_UnitTest__Config, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UnitTest__Config
local UnitTest, protected = Xist_Module.Install(ModuleName, ModuleVersion, Xist_UnitTest:New(ModuleName))

-- Add this class to the unit test framework
Xist_UnitTestFramework:AddClass(UnitTest)


UnitTest:AddTest('GetKey string', function()
    local config = Xist_Config:New({a=1})
    assert(config:GetKey('a') == 1)
end)


UnitTest:AddTest('GetKey array', function()
    local config = Xist_Config:New({a=1})
    assert(config:GetKey({'a'}) == 1)
end)


UnitTest:AddTest('Nil Config Gets', function()
    local config = Xist_Config:New(nil)
    assert(config:GetConfig() == nil, 'Expect nil from GetConfig() with nil config')
    assert(config:GetKey('foo') == nil, 'Expect nil from GetKey() with nil config')
    assert(config:GetKey({'foo'}) == nil, 'Expect nil from GetKey() with nil config')
    local lineage = config:GetLineage()
    assert(#lineage == 1, 'Expect only self in lineage since no parent')
end)


UnitTest:AddTest('Nil Config Sets', function()
    local config = Xist_Config:New(nil)
    config:SetKey({'foo','bar'}, true)
    assert(config:GetKey({'foo','bar'}) == true)
end)


UnitTest:AddTest('Lineage Order', function()
    local confs = {}
    local maxN = 5
    for i = 1, maxN do
        confs[#confs+1] = Xist_Config:New({i=i}, #confs > 0 and confs[#confs] or nil)
    end
    for i = 1, #confs do
        local lineage = confs[i]:GetLineage()
        assert(#lineage == i, 'Lineage for confs['..i..'] should be '..i..' elements')
    end
    local child = confs[#confs] -- the last one
    local parent = child.parent
    local grandparent = parent.parent
    assert(child:GetKey('i') == maxN)
    assert(parent:GetKey('i') == maxN-1)
    assert(grandparent:GetKey('i') == maxN-2)
end)


UnitTest:AddTest('SetKeyInLowestNonEmptyNamespace', function()
    local c1 = Xist_Config:New({a=1})
    local c2 = Xist_Config:New(nil, c1)
    local c3 = Xist_Config:New(nil, c2)
    -- set in lowest non-empty namespace, which is c1
    c3:SetKeyInLowestNonEmptyNamespace('b', 1)
    -- we expect that c1 is where the change occurred
    assert(c1:GetKey('b') == 1)
end)


UnitTest:AddTest('New Config Creates Copy', function()
    local data = {a=1}
    local config = Xist_Config:New(data)
    data.a = 2
    local result = config:GetConfig()
    assert(result.a == 1, "Config was affected by local changes")
end)


UnitTest:AddTest('GetConfig returns Copy', function()
    local data = {a=1}
    local config = Xist_Config:New(data)
    local result = config:GetConfig()
    result.a = 2 -- change local result after GetConfig()
    data = config:GetConfig() -- some other code later calls GetConfig()
    assert(data.a == 1, "Config was affected by local changes")
end)


UnitTest:AddTest('Override changes value', function()
    local config = Xist_Config:New({a=1})
    config:Override({a=2})
    local result = config:GetConfig()
    assert(result.a == 2, "Override failed")
end)


UnitTest:AddTest('Override deletes value', function()
    local config = Xist_Config:New({a=1})
    config:Override({a=Xist_Config.NIL})
    local result = config:GetConfig()
    assert(result.a == nil, "Delete failed")
end)


UnitTest:AddTest('Parent config without overrides', function()
    local parentConfig = Xist_Config:New({a=1})
    local config = Xist_Config:New({}, parentConfig)
    local result = config:GetConfig()
    assert(result.a == 1, "Config does not contain parent settings")
end)


UnitTest:AddTest('Parent config with override', function()
    local parentConfig = Xist_Config:New({a=1})
    local config = Xist_Config:New({a=2}, parentConfig)
    local result = config:GetConfig()
    assert(result.a == 2, "Config override is not in effect")
end)


UnitTest:AddTest('Deep parent config delete', function()
    local parentConfig = Xist_Config:New({a=1, b={true}})
    local config = Xist_Config:New({b=Xist_Config.NIL}, parentConfig)
    local result = config:GetConfig()
    assert(result.b == nil, "Delete of a table did not work")
end)


UnitTest:AddTest('Deep parent config delete', function()
    local parentConfig = Xist_Config:New({a=1, b={true}})
    local config = Xist_Config:New({b=Xist_Config.NIL}, parentConfig)
    local result = config:GetConfig()
    assert(result.b == nil, "Delete of a table did not work")
end)


UnitTest:AddTest('Deep parent config override partial', function()
    local parentConfig = Xist_Config:New({a=1, b={c={d=1, e=1}}})
    local config = Xist_Config:New({b={c={e=2}}}, parentConfig)
    local result = config:GetConfig()
    assert(type(result.b) == 'table')
    assert(type(result.b.c) == 'table')
    assert(result.b.c.d == 1, "D should have the parent's value")
    assert(result.b.c.e == 2, "E should have the override value")
end)


UnitTest:AddTest('Nested hierarchy config', function()
    local c1 = Xist_Config:New({a=1})
    local c2 = Xist_Config:New({}, c1)
    local c3 = Xist_Config:New({}, c2)
    local c4 = Xist_Config:New({}, c3)
    local r = c4:GetConfig()
    assert(r.a == 1, "Hierarchy failure")
end)


UnitTest:AddTest('Nested hierarchy override propagates', function()
    local c1 = Xist_Config:New({a=1})
    local c2 = Xist_Config:New({}, c1)
    local c3 = Xist_Config:New({}, c2)
    local c4 = Xist_Config:New({}, c3)
    local r = c4:GetConfig()
    assert(r.a == 1, "Hierarchy failure")
    assert(r.b == nil, "Data should not yet exist")
    c2:Override({b=2}) -- override c4's grandparent
    assert(c2:IsDirty(), "Should be dirty after Override")
    r = c4:GetConfig()
    assert(r.b == 2, "Grandparent override failed to propagate")
end)


UnitTest:AddTest('GetKey deep value exists', function()
    local conf = Xist_Config:New({a={b={c={d=true}}}})
    assert(conf:GetKey({'a'}).b ~= nil)
    assert(conf:GetKey({'a','b'}).c ~= nil)
    assert(conf:GetKey({'a','b','c'}).d ~= nil)
    assert(conf:GetKey({'a','b','c','d'}) == true)
end)


UnitTest:AddTest('GetKey deep value not exists', function()
    local conf = Xist_Config:New({a={b={c={d=true}}}})
    assert(conf:GetKey({'z'}) == nil)
    assert(conf:GetKey({'a','z'}) == nil)
    assert(conf:GetKey({'a','b','z'}) == nil)
    assert(conf:GetKey({'a','b','c','d','e','f','g'}) == nil)
end)


UnitTest:AddTest('SetKey top level', function()
    local conf = Xist_Config:New({a=1})
    conf:SetKey({'a'}, 2)
    assert(conf:GetKey({'a'}) == 2)
end)


UnitTest:AddTest('SetKey deep level', function()
    local conf = Xist_Config:New({a={b={c={d=1, e=1}}}})
    conf:SetKey({'a','b','c','d'}, 2)
    assert(conf:GetKey({'a','b','c','d'}) == 2, "D should be changed")
    assert(conf:GetKey({'a','b','c','e'}) == 1, "E should be unchanged")
end)


UnitTest:AddTest('SetKey new deep level', function()
    local conf = Xist_Config:New()
    conf:SetKey({'a','b','c','d'}, 2)
    assert(conf:GetKey({'a','b','c','d'}) == 2, "D should exist with correct value")
end)


UnitTest:AddTest('ApplyNestedOverrides replace simple value with table', function()
    local parent = {a = 1}
    local child = {a = {b = 1}}
    Xist_Config:ApplyNestedOverrides(parent, child)
    assert(parent.a ~= nil)
    assert(type(parent.a) == 'table', 'Expect parent.a to be a table after override')
end)
