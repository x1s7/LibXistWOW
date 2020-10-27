
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
        defaultLineHeight = 12,
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

    -- here we use default lineHeight == 12 if the scrollChild widget does not support
    -- a GetLineHeight method.  12 is a random guess (font size 12px).  Is there a better guess?
    local lineHeight = scrollChild.GetLineHeight and scrollChild:GetLineHeight() or env:GetEnv('defaultLineHeight') or 12

    local slider = Xist_UI:Slider(widget)

    slider:SetValueStep(lineHeight)
    slider:RegisterEvent('OnValueChanged', Xist_Util.Bind(widget, widget.OnScrollEvent))

    widget.slider = slider

    -- AFTER setting the dimensions of the scrollFrame
    widget:SetScrollChild(scrollChild)
end


function Xist_UI_Widget_ScrollFrame:OnScrollEvent(value, delta)
    local max = self.slider:GetMaxValue()

    if protected.DebugEnabled then
        print('SF OnScrollEvent value='.. value ..' delta='.. delta ..' max='.. max ..' max-value='.. (max-value))
    end

    -- if we want to anchor to TOP, then do this:
    --self.scrollChild:SetPoint('TOP', self, 'TOP', 0, value)

    self.scrollChild:SetPoint('BOTTOM', self, 'BOTTOM', 0, value - max)
end


function Xist_UI_Widget_ScrollFrame:SetScrollChild(child)
    self:_SetScrollChild(child)
    self.scrollChild = child
    child:SetParent(self)
    -- the child must NOT be clamped to screen, it's possible that portions of it will be WAY off screen
    child:SetClampedToScreen(false)
end


function Xist_UI_Widget_ScrollFrame:OnMouseWheel(direction)
    local slider = self.slider
    local value = slider:GetValue() + (-direction * slider:GetValueStep())

    if protected.DebugEnabled then
        local min, max = slider:GetMinMaxValues()
        print('  slider min='.. min ..' max='.. max ..' value='.. value)
    end

    slider:SetValue(value)
end




function Xist_UI_Widget_ScrollFrame:Redraw()
    local innerHeight = self.scrollChild:GetTotalHeight()
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
