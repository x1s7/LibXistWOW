
local ModuleName = "Xist_UnitTest__Queue"
local ModuleVersion = 1

-- If some other addon installed Xist_UnitTest__Config, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UnitTest__Queue
local UnitTest, protected = Xist_Module.Install(ModuleName, ModuleVersion, Xist_UnitTest:New(ModuleName))

-- Add this class to the unit test framework
Xist_UnitTestFramework:AddClass(UnitTest)



local function AllocateN(q, n)
    for _=1, n do
        q:Allocate()
    end
end


local function IterateCount(q)
    local i = 0
    for _ in q:Iterate() do
        i = i + 1
    end
    return i
end


UnitTest:AddTest('Single Element Queue', function()
    local q = Xist_Queue:New(1)

    local item = q:Allocate()
    assert(item.reset == nil)

    item = q:Allocate()
    assert(item.reset == true)
end)


UnitTest:AddTest('Double Element Queue', function()
    local q = Xist_Queue:New(2)
    local item

    for i = 1, 5 do
        local expectedResetValue = (i > 1) and true or nil

        item = q:Allocate()
        assert(item.index == 1, 'item.index='.. item.index)
        assert(item.reset == expectedResetValue)

        item = q:Allocate()
        assert(item.index == 2, 'item.index='.. item.index)
        assert(item.reset == expectedResetValue)
    end
end)


UnitTest:AddTest('GetLength', function()
    local qSize = 2
    local q = Xist_Queue:New(qSize)

    assert(q:GetLength() == 0)

    -- allocate 1 more than the queue size so it will wrap around
    for i=1, qSize+1 do
        q:Allocate()

        -- expect length of queue is the max size, not number-of-times-allocated
        assert(q:GetLength() == math.min(i, qSize))
    end
end)


UnitTest:AddTest('Iterate over zero-item list', function()
    local q = Xist_Queue:New(2)

    for _ in q:Iterate() do
        error('Iterate should have returned nil with zero items in the list')
    end
end)


UnitTest:AddTest('Iterate over small sequential list', function()
    local qSize = 2
    local q = Xist_Queue:New(qSize)

    AllocateN(q, qSize)

    -- iterate over the items in the list
    local n = 0
    for item in q:Iterate() do
        n = n + 1
        if n > q:GetMaxLength() then
            error('Iteration should have stopped before now! n='.. n ..'; qLen='.. q:GetMaxLength())
        end
        assert(item.index == n)
    end

    assert(n == q:GetLength(), 'Expected to iterate each item in the queue')
end)


UnitTest:AddTest('Iterate over non-sequential list', function()
    local qSize = 5
    local q = Xist_Queue:New(qSize)

    AllocateN(q, qSize + 2)

    -- iterate over the items in the list
    local n = 0
    for item in q:Iterate() do
        n = n + 1
        if n > q:GetMaxLength() then
            error('Iteration should have stopped before now! n='.. n ..'; qLen='.. q:GetMaxLength())
        end
        assert(item.index == n)
    end

    assert(n == q:GetLength(), 'Expected to iterate each item in the queue')
end)


UnitTest:AddTest('Allocate for non-max-length Queue', function()
    local q = Xist_Queue:New() -- no maximum size
    AllocateN(q, 5)
    assert(q:GetLength() == 5)
    assert(q:GetMaxLength() == 0)
end)


UnitTest:AddTest('Custom data persists', function()
    local qSize = 5
    local q = Xist_Queue:New(qSize)

    -- allocate the queue with custom values
    for i=1, qSize do
        q:Allocate({value = i})
    end

    -- iterate over the queue
    local i = 1
    for item in q:Iterate() do
        assert(item.value == i)
        i = i + 1
    end
end)


UnitTest:AddTest('Resize with Reorder preserves ordering', function()
    local qSize = 5
    local extra = 2
    local q = Xist_Queue:New(qSize)

    -- allocate the queue
    for i=1, qSize+extra do
        q:Allocate({value = i})
    end

    local items = {}
    for item in q:Iterate() do
        table.insert(items, item)
    end

    q:SetMaxLength(qSize+extra)

    local i = 1
    for item in q:Iterate() do
        assert(items[i].value == item.value, 'Expect '.. items[i].value ..'='.. item.value)
        i = i + 1
    end

end)


UnitTest:AddTest('Resize increases buffer size', function()
    local qSize = 3
    local expandedSize = qSize + 2
    local q = Xist_Queue:New(qSize)

    AllocateN(q, qSize)
    q:SetMaxLength(expandedSize)
    AllocateN(q, expandedSize)

    assert(q:GetLength() == expandedSize)
end)
