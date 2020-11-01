
local ModuleName = "Xist_UnitTest__Core__Util"
local ModuleVersion = 1

-- If some other addon installed Xist_UnitTest__Config, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UnitTest__Config
local UnitTest, protected = Xist_Module.Install(ModuleName, ModuleVersion, Xist_UnitTest:New(ModuleName))

-- Add this class to the unit test framework
Xist_UnitTestFramework:AddClass(UnitTest)


UnitTest:AddTest('ToList nil', function(self)
    local s = Xist_Util.ToList()
    assert(type(s) == 'table')
    assert(#s == 0)
end)


UnitTest:AddTest('ToList single element', function(self)
    local s = Xist_Util.ToList(4)
    assert(type(s) == 'table')
    assert(#s == 1)
    assert(s[1] == 4)
end)


UnitTest:AddTest('ToList multiple elements', function(self)
    local s = Xist_Util.ToList(1,2,3,4)
    assert(type(s) == 'table')
    assert(#s == 4)
    assert(s[1] == 1)
    assert(s[2] == 2)
    assert(s[3] == 3)
    assert(s[4] == 4)
end)


UnitTest:AddTest('CountDigits(1)', function(self)
    local n = 1
    local expected = 1
    local actual = Xist_Util.CountDigits(n)
    assert(expected == actual, self:ExpectedEqual(expected, actual))
end)


UnitTest:AddTest('CountDigits(10)', function(self)
    local n = 10
    local expected = 2
    local actual = Xist_Util.CountDigits(n)
    assert(expected == actual, self:ExpectedEqual(expected, actual))
end)


UnitTest:AddTest('CountDigits(1.1111)', function(self)
    local n = 1.1111
    local expected = 1
    local actual = Xist_Util.CountDigits(n)
    assert(expected == actual, self:ExpectedEqual(expected, actual))
end)


UnitTest:AddTest('CountDigits loop', function(self)
    local actual
    local expected = 1
    for n=0, 9 do -- 0 to 9
        actual = Xist_Util.CountDigits(n)
        assert(expected == actual, 'n=='..n..' '.. self:ExpectedEqual(expected, actual))
    end

    expected = 2
    for n=10, 99, 3 do -- 10 to 99 by +3
        actual = Xist_Util.CountDigits(n)
        assert(expected == actual, 'n=='..n..' '.. self:ExpectedEqual(expected, actual))
    end

    expected = 3
    for n=100, 999, 11 do -- 100 to 999 by +11
        actual = Xist_Util.CountDigits(n)
        assert(expected == actual, 'n=='..n..' '.. self:ExpectedEqual(expected, actual))
    end

    expected = 4
    for n=1000, 9999, 111 do -- 1000 to 9999 by +111
        actual = Xist_Util.CountDigits(n)
        assert(expected == actual, 'n=='..n..' '.. self:ExpectedEqual(expected, actual))
    end

    local n = 1
    expected = 1
    while n < 100000000000 do
        actual = Xist_Util.CountDigits(n)
        assert(expected == actual, 'n=='..n..' '.. self:ExpectedEqual(expected, actual))
        expected = expected + 1
        n = n * 10
    end
end)


UnitTest:AddTest('Join single word', function(self)
    local words = {'a'}
    local result = Xist_Util.Join(words, ',')
    local expected = 'a'
    assert(expected == result, self:ExpectedEqual(expected, result))
end)


UnitTest:AddTest('Join N words', function(self)
    local words = {'a','b','c'}
    local result = Xist_Util.Join(words, ',')
    local expected = 'a,b,c'
    assert(expected == result, self:ExpectedEqual(expected, result))
end)


UnitTest:AddTest('Join 1 parameter', function(self)
    local words = {'a','b','c'}
    local result = Xist_Util.Join(words)
    local expected = 'abc'
    assert(expected == result, self:ExpectedEqual(expected, result))
end)


UnitTest:AddTest('Split2 nil nil', function(self)
    local str = nil
    local delimiter = nil
    local expected = nil
    local actual = Xist_Util.Split2(str, delimiter)
    assert(expected == actual, self:ExpectedEqual(expected, actual))
end)


UnitTest:AddTest('Split2 nil /', function(self)
    local str = nil
    local delimiter = '/'
    local expected = nil
    local actual = Xist_Util.Split2(str, delimiter)
    assert(expected == actual, self:ExpectedEqual(expected, actual))
end)


UnitTest:AddTest('Split2 a/b nil', function(self)
    local str = 'a/b'
    local delimiter = nil
    local expected = str
    local actual = Xist_Util.Split2(str, delimiter)
    assert(expected == actual, self:ExpectedEqual(expected, actual))
end)


UnitTest:AddTest('Split2 a/b/c /', function(self)
    local str = 'a/b'
    local delimiter = '/'
    local expected1, expected2 = 'a', 'b'
    local actual1, actual2 = Xist_Util.Split2(str, delimiter)
    assert(expected1 == actual1, self:ExpectedEqual(expected1, actual1))
    assert(expected2 == actual2, self:ExpectedEqual(expected2, actual2))
end)


UnitTest:AddTest('Slice', function(self)
    local a = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    local expected = {3, 4, 5}
    local actual = Xist_Util.Slice(a, 3, 3)
    assert(type(actual) == 'table')
    assert(#expected == #actual, self:ExpectedEqual(#expected, #actual))
    for i=1, #expected do
        assert(expected[i] == actual[i], 'i='..i..' '.. self:ExpectedEqual(expected[i], actual[i]))
    end
end)


UnitTest:AddTest('Slice negative', function(self)
    local a = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    local expected = {9, 10}
    local actual = Xist_Util.Slice(a, -2)
    assert(type(actual) == 'table')
    assert(#expected == #actual, self:ExpectedEqual(#expected, #actual))
    for i=1, #expected do
        assert(expected[i] == actual[i], 'i='..i..' '.. self:ExpectedEqual(expected[i], actual[i]))
    end
end)


UnitTest:AddTest('MergeInto', function(self)
    local a = {x=1, y=2}
    local b = {x=2, z=3}
    local expected = {x=2, y=2, z=3}
    local actual = Xist_Util.MergeInto(a, b)
    assert(#expected == #actual, self:ExpectedEqual(#expected, #actual))
    assert(expected[1] == actual[1], self:ExpectedEqual(expected[1], actual[1]))
    assert(expected[2] == actual[2], self:ExpectedEqual(expected[2], actual[2]))
    assert(expected[3] == actual[3], self:ExpectedEqual(expected[3], actual[3]))
end)


UnitTest:AddTest('MergeInto overwrites external data', function(self)
    local a = {x=1, y=2}
    local b = {x=2, z=3}
    local _ = Xist_Util.MergeInto(a, b)
    -- after MergeInto, values of `a' should have been updated
    assert(a.x == b.x, self:ExpectedEqual(a.x, b.x))
end)


UnitTest:AddTest('Merge', function(self)
    local a = {x=1, y=2}
    local b = {x=2, z=3}
    local expected = {x=2, y=2, z=3}
    local actual = Xist_Util.Merge(a, b)
    assert(#expected == #actual, self:ExpectedEqual(#expected, #actual))
    assert(expected[1] == actual[1], self:ExpectedEqual(expected[1], actual[1]))
    assert(expected[2] == actual[2], self:ExpectedEqual(expected[2], actual[2]))
    assert(expected[3] == actual[3], self:ExpectedEqual(expected[3], actual[3]))
end)


UnitTest:AddTest('Merge does not overwrite external data', function(self)
    local a = {x=1, y=2}
    local b = {x=2, z=3}
    local _ = Xist_Util.Merge(a, b)
    -- after MergeInto, values of `a' should have been updated
    assert(1 == a.x, self:ExpectedEqual(1, a.x))
end)


UnitTest:AddTest('Keys Sequential', function(self)
    local tbl = {1, 2}
    local keys = Xist_Util.Keys(tbl)
    assert(2 == #keys)
    assert(1 == keys[1])
    assert(2 == keys[2])
end)


UnitTest:AddTest('Keys Assoc', function(self)
    local tbl = {a=1, b=2}
    local keys = Xist_Util.Keys(tbl)
    assert(2 == #keys)
    assert('a' == keys[1])
    assert('b' == keys[2])
end)


UnitTest:AddTest('PairsByKeys default sort', function(self)
    local data = {
        c = 1,
        b = 2,
        a = 3,
    }
    local keys = {}
    local values = {}
    for k, v in Xist_Util.PairsByKeys(data) do
        table.insert(keys, k)
        table.insert(values, v)
    end
    assert(3 == #keys)
    assert(3 == #values)
    assert('a' == keys[1]) -- 'a' < 'b' regardless of value
    assert(3 == values[1])
    assert('b' == keys[2]) -- 'b' < 'c' regardless of value
    assert(2 == values[2])
    assert('c' == keys[3])
    assert(1 == values[3])
end)


UnitTest:AddTest('PairsByKeys default sort', function(self)
    local data = {
        c = 1,
        b = 2,
        a = 3,
    }
    local comp = function(a, b)
        return data[a] < data[b]
    end
    local keys = {}
    local values = {}
    for k, v in Xist_Util.PairsByKeys(data, comp) do
        table.insert(keys, k)
        table.insert(values, v)
    end
    assert(3 == #keys)
    assert(3 == #values)
    assert('c' == keys[1]) -- 'c' key has lowest value
    assert(1 == values[1])
    assert('b' == keys[2]) -- 'b' key has middle value
    assert(2 == values[2])
    assert('a' == keys[3]) -- 'a' key has highest value
    assert(3 == values[3])
end)


UnitTest:AddTest('Copy nil', function(self)
    local orig = nil
    local copy = Xist_Util.Copy(orig)
    assert(copy == nil)
end)


UnitTest:AddTest('Copy simple', function(self)
    local values = {1, true, 'string'}
    local orig, copy
    for i=1, #values do
        orig = values[i]
        copy = Xist_Util.Copy(orig)
        local origType = type(orig)
        local copyType = type(copy)
        assert(origType == copyType, self:ExpectedEqual(origType, copyType))
        assert(orig == copy, self:ExpectedEqual(orig, copy))
    end
end)


UnitTest:AddTest('Copy simple table', function(self)
    local orig = {a=1, b=2, c=3}
    local copy = Xist_Util.Copy(orig)
    assert(type(copy) == 'table')
    assert(copy.a == 1)
    assert(copy.b == 2)
    assert(copy.c == 3)
end)


UnitTest:AddTest('Copy less simple table', function(self)
    local t1 = {a=1, b=2, c=3}
    local t2 = {a=4, b=5, c=6}
    local orig = {t1=t1, t2=t2}
    local copy = Xist_Util.Copy(orig)
    assert(type(copy) == 'table')
    assert(type(copy.t1) == 'table')
    assert(type(copy.t2) == 'table')
    assert(copy.t1.a == 1)
    assert(copy.t1.b == 2)
    assert(copy.t1.c == 3)
    assert(copy.t2.a == 4)
    assert(copy.t2.b == 5)
    assert(copy.t2.c == 6)
end)


UnitTest:AddTest('Modify copied table references does not overwrite external data', function(self)
    local t1 = {a=1, b=2, c=3}
    local t2 = {a=4, b=5, c=6}
    local orig = {t1=t1, t2=t2}
    local copy = Xist_Util.Copy(orig)
    copy.t1.a = 7 -- change the value of the copy
    assert(t1.a == 1, 'Original t1.a should not have changed')
end)


UnitTest:AddTest('Bind', function(self)
    local method = function(a, b, c) return {a, b, c} end
    local obj = {isMyObj = true}
    local callback = Xist_Util.Bind(obj, method)
    assert(type(callback) == 'function')
    local result = callback(1, 2) -- call with 2 arguments
    assert(type(result) == 'table')
    assert(#result == 3)
    assert(result[1].isMyObj == true, self:ExpectedTrue(result[1].isMyObj))
    assert(result[2] == 1, self:ExpectedEqual(1, result[2]))
    assert(result[3] == 2, self:ExpectedEqual(2, result[3]))
end)
