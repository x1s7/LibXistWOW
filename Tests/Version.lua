
local ModuleName = "Xist_UnitTest__Version"
local ModuleVersion = 1

-- If some other addon installed Xist_UnitTest__Config, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UnitTest__Config
local UnitTest, protected = Xist_Module.Install(ModuleName, ModuleVersion, Xist_UnitTest:New(ModuleName))

-- Add this class to the unit test framework
Xist_UnitTestFramework:AddClass(UnitTest)


UnitTest:AddTest('New()', function(self)
    local v = Xist_Version:New()
    assert(v.major == 0, self:ExpectedEqual(0, v.major))
    assert(v.minor == 0, self:ExpectedEqual(0, v.minor))
    assert(v.patch == 0, self:ExpectedEqual(0, v.patch))
    assert(v.tag == nil, self:ExpectedEqual(nil, v.tag))
end)


UnitTest:AddTest('New(number)', function(self)
    local v = Xist_Version:New(1)
    assert(v.major == 1, self:ExpectedEqual(1, v.major))
    assert(v.minor == 0, self:ExpectedEqual(0, v.minor))
    assert(v.patch == 0, self:ExpectedEqual(0, v.patch))
    assert(v.tag == nil, self:ExpectedEqual(nil, v.tag))
end)


UnitTest:AddTest('New(Xist_Version)', function(self)
    local v = Xist_Version:New()
    v.major = 2
    v.minor = 3
    v.patch = 4
    v.tag = 'test'
    local v2 = Xist_Version:New(v)
    assert(v.major == v2.major, self:ExpectedEqual(v.major, v2.major))
    assert(v.minor == v2.minor, self:ExpectedEqual(v.minor, v2.minor))
    assert(v.patch == v2.patch, self:ExpectedEqual(v.minor, v2.minor))
    assert(v.tag == v2.tag, self:ExpectedEqual(v.tag, v2.tag))
end)


UnitTest:AddTest('New(string)', function(self)
    local v = Xist_Version:New('3.4.5-foo')
    assert(v.major == 3, self:ExpectedEqual(3, v.major))
    assert(v.minor == 4, self:ExpectedEqual(4, v.minor))
    assert(v.patch == 5, self:ExpectedEqual(5, v.patch))
    assert(v.tag == 'foo', self:ExpectedEqual('foo', v.tag))
end)


UnitTest:AddTest('New(string,string,string,string)', function(self)
    local v = Xist_Version:New('3', '4', '5', 'foo')
    assert(v.major == 3, self:ExpectedEqual(3, v.major))
    assert(v.minor == 4, self:ExpectedEqual(4, v.minor))
    assert(v.patch == 5, self:ExpectedEqual(5, v.patch))
    assert(v.tag == 'foo', self:ExpectedEqual('foo', v.tag))
end)


UnitTest:AddTest('Operator ==', function(self)
    local v1 = Xist_Version:New(1, 2, 3)

    local v2 = Xist_Version:New(1, 2, 3)
    assert(v1 == v2, self:ExpectedEqual(v1, v2))

    v2 = Xist_Version:New(v1)
    assert(v1 == v2, self:ExpectedEqual(v1, v2))

    v2 = v1
    assert(v1 == v2, self:ExpectedEqual(v1, v2))
end)


UnitTest:AddTest('Operator <', function(self)
    local v1 = Xist_Version:New(1, 2, 3)

    local v2 = Xist_Version:New(1, 2, 4) -- patch bump
    assert(v1 < v2, self:ExpectedLessThan(v1, v2))

    v2 = Xist_Version:New(1, 3) -- minor bump
    assert(v1 < v2, self:ExpectedLessThan(v1, v2))

    v2 = Xist_Version:New(2) -- major bump
    assert(v1 < v2, self:ExpectedLessThan(v1, v2))
end)


UnitTest:AddTest('Operator <=', function(self)
    local v1 = Xist_Version:New(1, 2, 3)

    local v2 = Xist_Version:New(1, 2, 4) -- patch bump
    assert(v1 <= v2, self:ExpectedLessOrEqual(v1, v2))

    v2 = Xist_Version:New(1, 3) -- minor bump
    assert(v1 <= v2, self:ExpectedLessOrEqual(v1, v2))

    v2 = Xist_Version:New(2) -- major bump
    assert(v1 <= v2, self:ExpectedLessOrEqual(v1, v2))

    v2 = v1 -- equal
    assert(v1 <= v2, self:ExpectedLessOrEqual(v1, v2))
end)
