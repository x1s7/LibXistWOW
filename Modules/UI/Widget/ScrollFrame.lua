
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


local inheritance = {Xist_UI_Widget_ScrollFrame}

local settings = {
    parent = 'frame',
}

local classes = {
    default = {
        topPadding = 0,
        leftPadding = 0,
        bottomPadding = 0,
        rightPadding = 0,
        defaultLineHeight = 12,
    },
}


function Xist_UI_Widget_ScrollFrame:InitializeScrollFrameWidget(scrollChild)
    local classConf = self:GetWidgetConfig()

    local parent = self:GetParent()
    local topOffset = parent.contentOffset or classConf.topPadding or 0
    local leftPadding = classConf.leftPadding or 0
    local bottomPadding = classConf.bottomPadding or 0
    local rightPadding = classConf.rightPadding or 0

    self:SetPoint('TOPLEFT', leftPadding, -topOffset)
    self:SetPoint('BOTTOMRIGHT', -rightPadding, bottomPadding)

    self:EnableMouse(true)
    self:EnableMouseWheel(true)

    self:SetScript('OnMouseWheel', self.OnMouseWheel)

    -- we expect the children to be BIGGER in dimensions than this scrollFrame.
    -- DON'T display the parts of the children that are outside of the area of this scrollFrame.
    self:SetClipsChildren(true)

    -- here we use default lineHeight == 12 if the scrollChild widget does not support
    -- a GetLineHeight method.  12 is a random guess (font size 12px).  Is there a better guess?
    local lineHeight = scrollChild.GetLineHeight and scrollChild:GetLineHeight() or classConf.defaultLineHeight or 12

    local slider = Xist_UI:Slider(self)

    slider:SetValueStep(lineHeight)
    slider:RegisterEvent('OnValueChanged', Xist_Util.Bind(self, self.OnScrollEvent))

    self.slider = slider

    -- AFTER setting the dimensions of the scrollFrame
    self:SetScrollChild(scrollChild)
end


function Xist_UI_Widget_ScrollFrame:OnScrollEvent(value, delta)
    local max = self.slider:GetMaxValue()

    if protected.DebugEnabled then
        print('SF OnScrollEvent value='.. value ..' delta='.. delta ..' max='.. max ..' max-value='.. (max-value))
    end

    -- if we want to anchor to TOP, then do this:
    --self.scrollChild:SetPoint('TOP', self, 'TOP', 0, value)

    self.scrollChild:SetPoint('BOTTOM', self, 'BOTTOM', 0, -(max - value))
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
    local obscuredHeight = math.max(0, innerHeight - visibleHeight)

    if obscuredHeight == 0 then
        self.slider:SetMinMaxValues(0, 0)
    else
        self.slider:SetMinMaxValues(0, obscuredHeight)
    end
end


function Xist_UI_Widget_ScrollFrame:DebugDump()
    self.slider:SetMinMaxValues(0, 1)

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


Xist_UI_Config:RegisterWidget('scrollFrame', inheritance, settings, classes)
