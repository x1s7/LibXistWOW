
local ModuleName = "Xist_UI_Widget_Table_Data"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Table_Data, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Table_Data
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Table_Data
Xist_UI_Widget_Table_Data = M


local inheritance = {Xist_UI_Widget_Table_Data}

local settings = {
    backdrop = false,
}

local classes = {
    default = {
    },
}


function Xist_UI_Widget_Table_Data:InitializeTableDataWidget()
    local env = self:GetWidgetEnvironment()
    local spacing = env:GetSpacing()

    self.tableWidget = self:GetParent()
    self.options = self.tableWidget.options
    self.tableData = {}
    self.tableDataRows = {}
    self.totalHeight = 0

    -- positioned under the header widget, taking up the entire available space
    self:SetPoint('TOPLEFT', self.tableWidget.headerWidget, 'BOTTOMLEFT', 0, -spacing.vbetween)
    self:SetPoint('BOTTOMRIGHT')
end


function Xist_UI_Widget_Table_Data:AddData(data)
    self.tableData[1+#self.tableData] = Xist_Util.Copy(data)
end


function Xist_UI_Widget_Table_Data:SetData(dataList)
    self.tableData = Xist_Util.Copy(dataList) or {}
    self.tableWidget:Update()
end


function Xist_UI_Widget_Table_Data:GetDataRow(index)
    return self.tableDataRows[index] -- possibly nil
end


function Xist_UI_Widget_Table_Data:GetOrCreateDataRow(index)
    if index > #self.tableDataRows then
        local row = Xist_UI:Frame(self, nil, 'tableDataRow')
        row:InitializeTableDataRowWidget(index)
        self.tableDataRows[index] = row
    end
    return self.tableDataRows[index]
end


local function makeDefaultSort(sortKey)
    return function(a, b)
        return a[sortKey] < b[sortKey]
    end
end


function Xist_UI_Widget_Table_Data:SortData()
    local index, asc = self.tableWidget:GetCurrentSortSetting()
    if index ~= nil then
        -- the user has selected to sort based on a column
        local option = self.options[index] or {}
        local sort = option.sort or makeDefaultSort(option.sortKey) -- ascending sort function
        local comp = sort
        if not asc then -- need to sort descending, swap the parameter order to achieve this
            comp = function(a, b) return sort(b, a) end
        end
        table.sort(self.tableData, comp)
    end
end


function Xist_UI_Widget_Table_Data:Update()
    -- 1) Sort data
    self:SortData()

    -- 2) Assign data to rows
    local totalHeight = 0
    for i=1, #self.tableData do
        local row = self:GetOrCreateDataRow(i)
        row:SetData(self.tableData[i])
        row:Update()
        row:Show() -- in case it was previously hidden, show it
        totalHeight = totalHeight + row:GetHeight()
    end

    -- 3) Hide empty rows (data may have been deleted)
    for i=#self.tableData, #self.tableDataRows do
        local row = self.tableDataRows[i]
        row:Hide()
    end

    self.totalHeight = totalHeight
end


function Xist_UI_Widget_Table_Data:UpdateWidth()
    for i=1, #self.tableData do
        self.tableDataRows[i]:UpdateWidth()
    end
end


Xist_UI_Config:RegisterWidget('tableData', inheritance, settings, classes)
