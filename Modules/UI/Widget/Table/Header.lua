
local ModuleName = "Xist_UI_Widget_Table_Header"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Table_Header, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Table_Header
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Table_Header
Xist_UI_Widget_Table_Header = M

protected.DebugEnabled = true

local DEBUG = protected.DEBUG

local inheritance = {Xist_UI_Widget_Table_Header}

local settings = {
    backdrop = true,
}

local classes = {
    default = {
        backdrop = Xist_Config.NIL,
        buttonClass = 'tableHeaderCell',
    },
}


local function OnHeaderCellMouseUp(headerCell, button)
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
    local padding = env:GetPadding()
    local cells = {}
    local maxHeight = 0
    local totalWidth = 0
    for i=1, #self.options do
        local option = self.options[i]
        DEBUG('InitializeTableHeaderCells['.. i ..'] option=', option)
        local cell = Xist_UI:Button(self)
        cell.columnIndex = i
        cell:HookScript('OnMouseUp', OnHeaderCellMouseUp)
        if i == 1 then
            cell:SetPoint('TOPLEFT', self, 'TOPLEFT', padding.left, -padding.top)
        else
            cell:SetPoint('TOPLEFT', cells[i-1], 'TOPRIGHT', padding.right + padding.left, 0)
        end
        -- set the text of the cell
        cell:SetText(option.title)
        -- THEN determine the width of the text if we're not forcing a certain width
        option.headerTitleWidth = cell:GetTextWidth()
        local width = option.width and option.width or option.headerTitleWidth
        -- set the height/width of the button
        cell:SetSize(width, cell:GetTextHeight())
        -- determine max height and total width
        local height = padding.top + cell:GetTextHeight() + padding.bottom
        if height > maxHeight then
            maxHeight = height
        end
        totalWidth = totalWidth + padding.left + width + padding.right
        -- save the cell
        cells[i] = cell
    end
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
        local headerCell = self.tableHeaderCells[i]
        if i == self.sortIndex then
            local sortPrefix = self.sortAscending and '˄' or '˅'
            headerCell:SetText(sortPrefix ..' '.. option.title)
        else
            -- make sure the text does not contain any sorting
            headerCell:SetText(option.title)
        end
    end
end


Xist_UI_Config:RegisterWidget('tableHeader', inheritance, settings, classes)
