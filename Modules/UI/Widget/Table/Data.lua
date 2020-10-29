
local ModuleName = "Xist_UI_Widget_Table_Data"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Table_Data, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Table_Data
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Table_Data
Xist_UI_Widget_Table_Data = M

--protected.DebugEnabled = true

local DEBUG_CAT = protected.DEBUG_CAT


local inheritance = {'Xist_UI_Widget_Table_Data'}

local settings = {
}

local classes = {
    default = {
        backdropClass = 'green',
        spacing = {
            h = 0,
            v = 2,
        },
    },
}


function Xist_UI_Widget_Table_Data:InitializeTableDataWidget()
    local env = self:GetWidgetEnvironment()

    self.spacing = env:GetSpacing()
    self.tableWidget = self:GetParent()
    self.options = self.tableWidget.options
    self.tableData = {}
    self.tableDataRows = {}
end


--- @param rowData table
function Xist_UI_Widget_Table_Data:AddData(rowData)
    self.tableData[1+#self.tableData] = Xist_Util.Copy(rowData)
end


--- @param tableDataReference table
function Xist_UI_Widget_Table_Data:SetDataReference(tableDataReference)
    if not tableDataReference then
        error('Table data reference must not be nil')
    end
    self.tableData = tableDataReference
end


function Xist_UI_Widget_Table_Data:GetDataRow(index)
    return self.tableDataRows[index] -- possibly nil
end


function Xist_UI_Widget_Table_Data:GetOrCreateDataRow(index)
    if index > #self.tableDataRows then
        local row = Xist_UI:Frame(self, nil, 'tableDataRow')
        row:InitializeTableDataRowWidget(index)
        self.tableDataRows[index] = row

        local previousRow = self:GetDataRow(index-1) -- possibly nil
        if not previousRow then
            -- anchor to the top/left of the table data widget
            row:SetPoint('TOPLEFT', self.spacing.left, -self.spacing.top)
            row:SetPoint('TOPRIGHT', -self.spacing.right, -self.spacing.top)
        else
            -- anchor to the previous data row
            row:SetPoint('TOPLEFT', previousRow, 'BOTTOMLEFT', 0, -self.spacing.vbetween)
            row:SetPoint('TOPRIGHT', previousRow, 'BOTTOMRIGHT', 0, -self.spacing.vbetween)
        end
    end
    return self.tableDataRows[index]
end


local function makeDefaultSort(data, sortKey)
    return function(key1, key2)
        return data[key1][sortKey] < data[key2][sortKey]
    end
end


function Xist_UI_Widget_Table_Data:SortData()
    local index, asc = self.tableWidget:GetCurrentSortSetting()
    local result = {}
    if index ~= nil then
        -- the user has selected to sort based on a column
        local option = self.options[index]
        -- get a function that sorts the data ascending
        local sort
        if option.sort then
            local widget = self
            sort = function(a, b) return option.sort(widget.tableData[a], widget.tableData[b]) end
        else
            sort = makeDefaultSort(self.tableData, option.sortKey or option.dataKey or index) -- ascending sort function
        end
        -- convert the sort function to descending if needed
        local comp = sort
        if not asc then -- need to sort descending, swap the parameter order to achieve this
            comp = function(a, b) return sort(b, a) end
        end
        -- execute the sort, store the new key order
        for key, _ in Xist_Util.PairsByKeys(self.tableData, comp) do
            result[1+#result] = key
        end
    else
        -- store the current random order of the keys
        for key, _ in pairs(self.tableData) do
            result[1+#result] = key
        end
    end
    return result
end


function Xist_UI_Widget_Table_Data:Update()
    -- 1) Sort data
    local sortedKeys = self:SortData()

    -- 2) Assign data to rows
    local height = self.spacing.top
    for i=1, #sortedKeys do
        local row = self:GetOrCreateDataRow(i)
        row:SetData(self.tableData[sortedKeys[i]])
        row:Update()
        row:Show() -- in case it was previously hidden, show it
        height = height + row:GetHeight() + self.spacing.vbetween
    end

    -- 3) Hide empty rows (data may have been deleted)
    for i=#sortedKeys+1, #self.tableDataRows do
        local row = self.tableDataRows[i]
        row:Hide()
    end

    -- adjust the height of the table to fit all the rows
    height = height - self.spacing.vbetween + self.spacing.bottom
    self:SetHeight(height)

    DEBUG_CAT('Update', {nRows=#sortedKeys, height=height})
end


function Xist_UI_Widget_Table_Data:UpdateWidth()
    for i=1, #self.tableDataRows do
        if self.tableDataRows[i]:IsShown() then
            self.tableDataRows[i]:UpdateWidth()
        end
    end
end


Xist_UI_Config:RegisterWidget('tableData', inheritance, settings, classes)
