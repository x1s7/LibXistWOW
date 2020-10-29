
local ModuleName = "Xist_UI_Widget_Table"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Table, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Table
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Table
Xist_UI_Widget_Table = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local DEBUG_CAT = protected.DEBUG_CAT


local inheritance = {'Xist_UI_Widget_Table'}

local settings = {
}

local classes = {
    default = {
        backdropClass = 'transparent',
        padding = 2,
        spacing = 2,
    },
}


local function InitializeTableWidget(widget, options)
    local env = widget:GetWidgetEnvironment()
    DEBUG('InitializeTableWidget')

    local parent = widget:GetParent()
    local topOffset = parent.contentOffset or 0
    local padding = env:GetPadding()

    widget:SetPoint('TOPLEFT', padding.left, -topOffset -padding.top)
    widget:SetPoint('BOTTOMRIGHT', -padding.right, padding.bottom)

    widget.options = options
    widget.headerWidget = Xist_UI:Frame(widget, nil, 'tableHeader')
    widget.dataWidget = Xist_UI:Frame(widget, nil, 'tableData')

    widget.headerWidget:InitializeTableHeaderWidget()
    widget.dataWidget:InitializeTableDataWidget()

    -- set contentOffset BEFORE creating the scrollFrame, it uses this info
    widget.contentOffset = widget.headerWidget:GetHeight() + padding.vbetween

    widget.scrollFrame = Xist_UI:ScrollFrame(widget, widget.dataWidget)
end


function Xist_UI_Widget_Table:GetCurrentSortSetting()
    return self.headerWidget:GetCurrentSortSetting()
end


--- @param rowData table
function Xist_UI_Widget_Table:AddData(rowData)
    self.dataWidget:AddData(rowData)
    self:Update()
end


--- @param tableDataReference table
function Xist_UI_Widget_Table:SetDataReference(tableDataReference)
    self.dataWidget:SetDataReference(tableDataReference)
    self:Update()
end


function Xist_UI_Widget_Table:NoteColumnWidthNeedsUpdate(columnIndex)
    self.widgetNoteColumnWidthNeedsUpdate = columnIndex -- discard any previous column, we just want to know true/false really
end


--- Update the table after something has changed.
function Xist_UI_Widget_Table:Update()
    -- reset width adjustment flag
    self.widgetNoteColumnWidthNeedsUpdate = nil

    -- update
    self.headerWidget:Update()
    self.dataWidget:Update()

    -- if width adjustments are necessary, update again
    if self.widgetNoteColumnWidthNeedsUpdate then
        self.headerWidget:UpdateWidth()
        self.dataWidget:UpdateWidth()
    end

    DEBUG_CAT('Update', {headerHeight=self.headerWidget:GetHeight(), dataHeight=self.dataWidget:GetHeight(), scrollHeight=self.scrollFrame:GetHeight()})

    self.scrollFrame:Redraw()
end


Xist_UI_Config:RegisterWidget('table', inheritance, settings, classes, InitializeTableWidget)
