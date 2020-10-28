
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


function Xist_UI_Widget_Table_Data:AddData(data)
    self.tableData[1+#self.tableData] = Xist_Util.Copy(data)
end


function Xist_UI_Widget_Table_Data:SetData(dataList)
    self.tableData = Xist_Util.Copy(dataList) or {}
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


local function makeDefaultSort(sortKey)
    return function(a, b)
        return a[sortKey] < b[sortKey]
    end
end


function Xist_UI_Widget_Table_Data:SortData()
    local index, asc = self.tableWidget:GetCurrentSortSetting()
    if index ~= nil then
        -- the user has selected to sort based on a column
        local option = self.options[index]
        local sort = option.sort or makeDefaultSort(option.sortKey or index) -- ascending sort function
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
    local height = self.spacing.top
    for i=1, #self.tableData do
        local row = self:GetOrCreateDataRow(i)
        row:SetData(self.tableData[i])
        row:Update()
        row:Show() -- in case it was previously hidden, show it
        height = height + row:GetHeight() + self.spacing.vbetween
    end

    -- 3) Hide empty rows (data may have been deleted)
    for i=#self.tableData + 1, #self.tableDataRows do
        local row = self.tableDataRows[i]
        row:Hide()
    end

    -- adjust the height of the table to fit all the rows
    height = height - self.spacing.vbetween + self.spacing.bottom
    self:SetHeight(height)

    DEBUG_CAT('Update', {nRows=#self.tableData, height=height})
end


function Xist_UI_Widget_Table_Data:UpdateWidth()
    for i=1, #self.tableData do
        self.tableDataRows[i]:UpdateWidth()
    end
end


Xist_UI_Config:RegisterWidget('tableData', inheritance, settings, classes)
