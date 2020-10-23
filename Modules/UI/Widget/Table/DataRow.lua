
local ModuleName = "Xist_UI_Widget_Table_DataRow"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Table_DataRow, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Table_DataRow
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Table_DataRow
Xist_UI_Widget_Table_DataRow = M

protected.DebugEnabled = true

local DEBUG = protected.DEBUG


local inheritance = {Xist_UI_Widget_Table_DataRow}

local settings = {
    backdrop = true,
}

local classes = {
    default = {
        backdropClass = 'tableDataCell',
        buttonClass = 'tableDataCell',
    },
}


local function OnDataCellMouseUp(cell, button)
    local tableDataRow = cell:GetParent()
    tableDataRow:HandleClickOnIndex(cell.columnIndex, button)
end


function Xist_UI_Widget_Table_DataRow:InitializeTableDataRowWidget(index)
    self.rowIndex = index
    self.tableDataWidget = self:GetParent()
    self.tableWidget = self.tableDataWidget.tableWidget
    self.options = self.tableDataWidget.options
    self.tableDataCells = self:InitializeTableDataCells()

    local previousRow = self.tableDataWidget:GetDataRow(index-1) -- possibly nil
    if not previousRow then
        -- anchor to the top/left of the table data widget
        self:SetPoint('TOPLEFT')
        self:SetPoint('TOPRIGHT')
    else
        -- anchor to the previous data row
        self:SetPoint('TOPLEFT', previousRow, 'BOTTOMLEFT')
        self:SetPoint('TOPRIGHT', previousRow, 'BOTTOMRIGHT')
    end

    self:SetHeight(self.tableDataWidget:GetRowHeight())
end


function Xist_UI_Widget_Table_DataRow:SetData(data)
    self.data = data
end


function Xist_UI_Widget_Table_DataRow:InitializeTableDataCells()
    local env = self:GetWidgetEnvironment()
    local padding = env:GetPadding()
    local rowHeight = self.tableDataWidget:GetRowHeight()
    local cells = {}
    for i=1, #self.options do
        local option = self.options[i]
        local cellClass = option.cellClass or nil -- nil means use the default class in this context
        DEBUG('InitializeTableDataCells['.. i ..'] option=', option)
        local cell = Xist_UI:Button(self, cellClass)
        cell.columnIndex = i
        cell:HookScript('OnMouseUp', OnDataCellMouseUp)
        if i == 1 then
            cell:SetPoint('TOPLEFT', self, 'TOPLEFT', padding.left, -padding.top)
        else
            cell:SetPoint('TOPLEFT', cells[i-1], 'TOPRIGHT', padding.right + padding.left, 0)
        end
        local width = option.width or option.headerTitleWidth
        cell:SetSize(width, rowHeight)
        cells[i] = cell
    end
    return cells
end


function Xist_UI_Widget_Table_DataRow:HandleClickOnIndex(index, button)
    if index < 1 or index > #self.options then
        error('Invalid index='.. index)
    end

    local option = self.options[index]
    if option.callback then
        if option.callback(option, self, index, button) == true then
            -- the callback instructed us to update
            self.tableWidget:Update()
        end
    end
end


function Xist_UI_Widget_Table_DataRow:Update()
    for i=1, #self.options do
        local option = self.options[i]

        local dataKey = option.dataKey or i
        local dataValue = self.data[dataKey]

        local cell = self.tableDataCells[i]
        cell:SetText(dataValue)
    end
end


Xist_UI_Config:RegisterWidget('tableDataRow', inheritance, settings, classes)
