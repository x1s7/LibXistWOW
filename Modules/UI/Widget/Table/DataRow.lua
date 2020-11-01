
local ModuleName = "Xist_UI_Widget_Table_DataRow"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Table_DataRow, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Table_DataRow
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Table_DataRow
Xist_UI_Widget_Table_DataRow = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG


local inheritance = {'Xist_UI_Widget_Table_DataRow'}

local settings = {
}

local classes = {
    default = {
        backdropClass = 'tableDataCell',
        buttonClass = 'tableDataCell',
        spacing = {
            h = 2,
            v = 0,
        },
    },
}


local function OnDataCellClick(cell, button)
    local tableDataRow = cell:GetParent()
    tableDataRow:HandleClickOnIndex(cell.columnIndex, button)
end


function Xist_UI_Widget_Table_DataRow:InitializeTableDataRowWidget(index)
    local env = self:GetWidgetEnvironment()

    self.rowIndex = index
    self.spacing = env:GetSpacing()
    self.tableDataWidget = self:GetParent()
    self.options = self.tableDataWidget.options
    self.tableWidget = self.tableDataWidget.tableWidget

    self.tableDataCells = self:InitializeTableDataCells()
end


function Xist_UI_Widget_Table_DataRow:SetData(data)
    self.data = data
end


function Xist_UI_Widget_Table_DataRow:InitializeTableDataCells()
    local env = self:GetWidgetEnvironment()
    local spacing = env:GetSpacing()
    local cells = {}
    for i=1, #self.options do
        local option = self.options[i]
        local cellClass = option.cellClass or nil -- nil means use the default class in this context
        DEBUG('InitializeTableDataCells['.. i ..'] option=', option)
        local cell = Xist_UI:Button(self, cellClass)
        cell.columnIndex = i
        cell:RegisterEvent('OnClick', OnDataCellClick)
        if i == 1 then
            cell:SetPoint('TOPLEFT', self, 'TOPLEFT', spacing.left, -spacing.top)
        else
            cell:SetPoint('TOPLEFT', cells[i-1], 'TOPRIGHT', spacing.hbetween, 0)
        end
        -- if the column defined a fixed with, assign it now
        if option.width ~= nil and option.width > 0 then
            cell:SetFixedWidth(option.width)
        end
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
    local maxHeight = 0
    local spacing = self.spacing

    for i=1, #self.options do
        local option = self.options[i]
        local cell = self.tableDataCells[i]

        local dataKey = option.dataKey or i
        local dataValue = self.data[dataKey]

        local formattedDataValue = dataValue
        if option.format then formattedDataValue = option.format(dataValue) end

        cell:SetText(formattedDataValue)

        local width = cell:GetWidth()
        if width > option.runtimeColumnWidth then
            DEBUG('Row', self.rowIndex, 'Column', i, 'maxWidth', option.runtimeColumnWidth, 'needs update to', width)
            option.runtimeColumnWidth = width
            self.tableWidget:NoteColumnWidthNeedsUpdate(i)
        elseif width < option.runtimeColumnWidth then
            -- though the cell doesn't require this much width, make it take the entire column width
            DEBUG('Row', self.rowIndex, 'Column', i, 'width', width, 'expanding to column max', option.runtimeColumnWidth)
            cell:SetWidth(option.runtimeColumnWidth)
        end

        local height = cell:GetHeight()
        if height > maxHeight then
            maxHeight = height
        end
    end

    self:SetHeight(spacing.top + maxHeight + spacing.bottom)
end


function Xist_UI_Widget_Table_DataRow:UpdateWidth()
    for i=1, #self.options do
        local option = self.options[i]
        local cell = self.tableDataCells[i]
        local width = cell:GetWidth()
        if width < option.runtimeColumnWidth then
            DEBUG('Row', self.rowIndex, 'Column', i, 'width', width, 'expanding to column max', option.runtimeColumnWidth)
            cell:SetWidth(option.runtimeColumnWidth)
        end
    end
end


Xist_UI_Config:RegisterWidget('tableDataRow', inheritance, settings, classes)
