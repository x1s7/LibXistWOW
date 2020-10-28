
local ModuleName = "Xist_UI_Widget_ScrollFrame"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_ScrollFrame, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_ScrollFrame
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_ScrollFrame
Xist_UI_Widget_ScrollFrame = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local MESSAGE = protected.MESSAGE


local inheritance = {'Xist_UI_Widget_ScrollFrame'}

local settings = {
    parent = 'frame',
}

local classes = {
    default = {
        padding = 0,
    },
}


local function InitializeScrollFrameWidget(widget, scrollChild)
    local env = widget:GetWidgetEnvironment()
    local padding = env:GetPadding()

    local parent = widget:GetParent()
    local topOffset = parent.contentOffset or 0

    widget:SetPoint('TOPLEFT', padding.left, -topOffset -padding.top)
    widget:SetPoint('BOTTOMRIGHT', -padding.right, padding.bottom)

    widget:EnableMouse(true)
    widget:EnableMouseWheel(true)

    widget:SetScript('OnMouseWheel', widget.OnMouseWheel)

    -- we expect the children to be BIGGER in dimensions than this scrollFrame.
    -- DON'T display the parts of the children that are outside of the area of this scrollFrame.
    widget:SetClipsChildren(true)

    -- make it take 20 scrolls to advance a page, with a minimum of 12px per scroll
    local scrollStep = math.max(12, math.floor(widget:GetHeight() / 20))

    local slider = Xist_UI:Slider(widget)

    slider:SetValueStep(scrollStep)
    slider:RegisterEvent('OnValueChanged', Xist_Util.Bind(widget, widget.OnScrollEvent))

    widget.slider = slider

    -- AFTER setting the dimensions of the scrollFrame
    widget:SetScrollChild(scrollChild)
end


--- Set the focus mode.
--- @param mode string TOP or BOTTOM
function Xist_UI_Widget_ScrollFrame:SetFocusMode(mode)
    self.focusMode = mode
    self.scrollChild:ClearAllPoints()
    self:SetScrollChildPoint()
end


function Xist_UI_Widget_ScrollFrame:SetScrollChildPoint()
    local min, max = self.slider:GetMinMaxValues()
    local value = self.slider:GetValue()

    if protected.DebugEnabled then
        print('SF SetScrollChildPoint '.. min ..' <= '.. value ..' <= '.. max)
    end

    if self.focusMode == 'BOTTOM' then
        self.scrollChild:SetPoint('BOTTOM', self, 'BOTTOM', 0, value - max)
    else
        self.scrollChild:SetPoint('TOP', self, 'TOP', 0, value)
    end
end


function Xist_UI_Widget_ScrollFrame:OnScrollEvent(value, delta)
    self:SetScrollChildPoint()
end


function Xist_UI_Widget_ScrollFrame:SetScrollChild(child)
    self:_SetScrollChild(child)
    self.scrollChild = child
    child:SetParent(self)
    -- the child must NOT be clamped to screen, it's possible that portions of it will be WAY off screen
    child:SetClampedToScreen(false)
    -- remove any previous points, we need to be able to move the scroll child around
    child:ClearAllPoints()
    child:SetWidth(self:GetWidth())
    child:SetHeight(self:GetHeight())
    self:SetScrollChildPoint()
end


function Xist_UI_Widget_ScrollFrame:OnMouseWheel(direction)
    local slider = self.slider
    local value = slider:GetValue() + (-direction * slider:GetValueStep())

    if protected.DebugEnabled then
        local min, max = slider:GetMinMaxValues()
        print('  slider '.. min ..' <= '.. value ..' <= '.. max)
    end

    slider:SetValue(value)
end


function Xist_UI_Widget_ScrollFrame:Redraw()
    local innerHeight = self.scrollChild:GetHeight() -- self.scrollChild:GetTotalHeight()
    local visibleHeight = self:GetHeight()
    local obscuredHeight = innerHeight - visibleHeight

    if obscuredHeight <= 0 then
        self.slider:SetMinMaxValues(0, 0)
    else
        self.slider:SetMinMaxValues(0, obscuredHeight)
    end
end


function Xist_UI_Widget_ScrollFrame:DebugDump()
    local m1 = {
        sliderH = self.slider:GetHeight(),
        sliderW = self.slider:GetWidth(),
    }
    local min,max = self.slider:GetMinMaxValues()
    local m2 = {
        sliderMax = max,
        sliderMin = min,
        sliderVal = self.slider:GetValue(),
    }

    -- this method is called "DebugDump" but really we want to see this even when
    -- debugging is disabled for this class.  This is called when a user clicks a
    -- "show me info" button, so SHOW it, debugging enabled or not.
    MESSAGE('ScrollFrame', m1, m2)
end


Xist_UI_Config:RegisterWidget('scrollFrame', inheritance, settings, classes, InitializeScrollFrameWidget)
