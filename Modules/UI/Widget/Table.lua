
local ModuleName = "Xist_UI_Widget_Table"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Table, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Table
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Table
Xist_UI_Widget_Table = M

protected.DebugEnabled = true

local DEBUG = protected.DEBUG


local inheritance = {Xist_UI_Widget_Table}

local settings = {
    backdrop = true,
}

local classes = {
    default = {
        backdropClass = 'red',
    },
}


local function InitializeTableWidget(widget, options)
    DEBUG('InitializeTableWidget')

    local parent = widget:GetParent()
    local topOffset = parent.contentOffset or 0
    local sidePadding = 0
    local bottomPadding = 0

    widget:SetPoint('TOPLEFT', sidePadding, -topOffset)
    widget:SetPoint('BOTTOMRIGHT', -sidePadding, bottomPadding)

    widget.options = options
    widget.headerWidget = Xist_UI:Frame(widget, nil, 'tableHeader')
    widget.dataWidget = Xist_UI:Frame(widget, nil, 'tableData')

    widget.headerWidget:InitializeTableHeaderWidget()
    widget.dataWidget:InitializeTableDataWidget()
end


function Xist_UI_Widget_Table:GetCurrentSortSetting()
    return self.headerWidget:GetCurrentSortSetting()
end


function Xist_UI_Widget_Table:AddData(data)
    self.dataWidget:AddData(data)
end


function Xist_UI_Widget_Table:SetData(dataList)
    self.dataWidget:SetData(dataList)
end


--- Update the table after something has changed.
function Xist_UI_Widget_Table:Update()
    self.headerWidget:Update()
    self.dataWidget:Update()
end


Xist_UI_Config:RegisterWidget('table', inheritance, settings, classes, InitializeTableWidget)
