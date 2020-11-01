
local ModuleName = "Xist_UI_Widget_Table_Header"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Table_Header, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Table_Header
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Table_Header
Xist_UI_Widget_Table_Header = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG

local inheritance = {'Xist_UI_Widget_Table_Header'}

local settings = {
}

local classes = {
    default = {
        backdropClass = 'transparent',
        buttonClass = 'tableHeaderCell',
        spacing = 2,
    },
}


local function OnHeaderCellClick(headerCell, button)
    local tableHeader = headerCell:GetParent()
    tableHeader:HandleClickOnIndex(headerCell.columnIndex, button)
end


function Xist_UI_Widget_Table_Header:InitializeTableHeaderWidget()
    self.tableWidget = self:GetParent()
    self.options = self.tableWidget.options

    local cells, height, width = self:InitializeTableHeaderCells()

    DEBUG('InitializeTableHeaderWidget', {width=width, height=height})

    self.tableHeaderCells = cells

    -- positioned at the top of the table taking only as much height as needed
    self:SetPoint('TOPLEFT')
    self:SetPoint('BOTTOMRIGHT', self.tableWidget, 'TOPRIGHT', 0, -height)
end


function Xist_UI_Widget_Table_Header:InitializeTableHeaderCells()
    local env = self:GetWidgetEnvironment()
    local spacing = env:GetSpacing()
    local cells = {}
    local maxHeight = 0
    local totalWidth = 0
    for i=1, #self.options do
        local option = self.options[i]
        local cellClass = option.cellHeaderClass or nil -- nil means use the default class in this context
        DEBUG('InitializeTableHeaderCells['.. i ..'] option=', option)
        local cell = Xist_UI:Button(self, cellClass)
        cell.columnIndex = i
        cell:RegisterEvent('OnClick', OnHeaderCellClick)
        if i == 1 then
            cell:SetPoint('TOPLEFT', self, 'TOPLEFT', spacing.left, -spacing.top)
        else
            cell:SetPoint('TOPLEFT', cells[i-1], 'TOPRIGHT', spacing.hbetween, 0)
        end
        -- if the column defined a fixed with, assign it now
        if option.width ~= nil and option.width > 0 then
            cell:SetFixedWidth(option.width)
        end
        -- set the text of the cell
        cell:SetText(option.title)
        -- THEN determine the width of the text if we're not forcing a certain width
        local width = cell:GetWidth()
        option.runtimeColumnWidth = width -- initialize the runtimeColumnWidth to the header width
        -- determine max height and total width
        local height = spacing.top + cell:GetHeight() + spacing.bottom
        if height > maxHeight then
            maxHeight = height
        end
        totalWidth = totalWidth + width + spacing.hbetween
        -- save the cell
        cells[i] = cell
    end
    -- in case vbetween ~= right, adjust right side spacing for the last cell
    totalWidth = totalWidth - spacing.hbetween + spacing.right
    return cells, maxHeight, totalWidth
end


function Xist_UI_Widget_Table_Header:HandleClickOnIndex(index, button)
    -- ignore all buttons but LeftButton
    if button ~= 'LeftButton' then
        return
    end
    if index < 1 or index > #self.options then
        error('Invalid index='.. index)
    end
    if index == self.sortIndex then
        -- they clicked the same index as before, toggle ascending/descending
        self.sortAscending = not self.sortAscending
    else
        -- they clicked a new/different index from before, sort ascending
        self.sortAscending = true
    end
    -- remember the column we're sorting by
    self.sortIndex = index
    -- redraw the table
    self.tableWidget:Update()
end


function Xist_UI_Widget_Table_Header:GetCurrentSortSetting()
    return self.sortIndex, self.sortAscending
end


function Xist_UI_Widget_Table_Header:Update()
    for i=1, #self.options do
        local option = self.options[i]
        local cell = self.tableHeaderCells[i]
        if i == self.sortIndex then
            local sortPrefix = self.sortAscending and '^' or 'v'
            cell:SetText(sortPrefix ..' '.. option.title)
        else
            -- make sure the text does not contain any sorting
            cell:SetText(option.title)
        end

        -- set the width based on option.runtimeColumnWidth
        local width = cell:GetWidth()
        if width > option.runtimeColumnWidth then
            DEBUG('Header Column', i, 'maxWidth', option.runtimeColumnWidth, 'needs update to', width)
            option.runtimeColumnWidth = width
            self.tableWidget:NoteColumnWidthNeedsUpdate(i)
        elseif width < option.runtimeColumnWidth then
            -- though the cell doesn't require this much width, make it take the entire column width
            DEBUG('Header Column', i, 'width', width, 'expanding to column max', option.runtimeColumnWidth)
            cell:SetWidth(option.runtimeColumnWidth)
        end
    end
end


function Xist_UI_Widget_Table_Header:UpdateWidth()
    for i=1, #self.options do
        local option = self.options[i]
        local cell = self.tableHeaderCells[i]
        local width = cell:GetWidth()
        if width < option.runtimeColumnWidth then
            DEBUG('Header Column', i, 'width', width, 'expanding to column max', option.runtimeColumnWidth)
            cell:SetWidth(option.runtimeColumnWidth)
        end
    end
end


Xist_UI_Config:RegisterWidget('tableHeader', inheritance, settings, classes)
