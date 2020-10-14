
local ModuleName = "Xist_UI_ScrollFrame"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_ScrollFrame, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_ScrollFrame
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_ScrollFrame
Xist_UI_ScrollFrame = M

protected.DebugEnabled = true

local DEBUG = protected.DEBUG


function Xist_UI_ScrollFrame:InitializeScrollFrameWidget(scrollChild)

    local parent = self:GetParent()
    local topOffset = parent.contentOffset or 0
    local sidePadding = 0
    local bottomPadding = 0

    self:SetPoint('TOPLEFT', sidePadding, -topOffset)
    self:SetPoint('BOTTOMRIGHT', -sidePadding, bottomPadding)

    self:EnableMouse(true)
    self:EnableMouseWheel(true)

    self:SetScript('OnMouseWheel', self.OnMouseWheel)

    self:SetClipsChildren(true)

    local lineHeight = scrollChild.GetLineHeight and scrollChild:GetLineHeight() or 12

    local slider = Xist_UI:Slider(self)

    slider:SetValueStep(lineHeight)
    slider:RegisterEvent('OnValueChanged', Xist_Util.Bind(self, self.OnScrollEvent))

    self.slider = slider

    -- AFTER setting the dimensions of the scrollFrame
    self:SetScrollChild(scrollChild)
end


function Xist_UI_ScrollFrame:OnScrollEvent(value, delta)
    local max = self.slider:GetMaxValue()
    print('SF OnScrollEvent value='.. value ..' delta='.. delta ..'max='.. max ..' max-value='.. (max-value))

    -- if we want to anchor to TOP, then do this:
    --self.scrollChild:SetPoint('TOP', self, 'TOP', 0, value)

    self.scrollChild:SetPoint('BOTTOM', self, 'BOTTOM', 0, -(max - value))
end


function Xist_UI_ScrollFrame:SetScrollChild(child)
    self:_SetScrollChild(child)
    self.scrollChild = child
    child:SetParent(self)
end


function Xist_UI_ScrollFrame:OnMouseWheel(direction)
    local slider = self.slider
    local value = slider:GetValue() + (-direction * slider:GetValueStep())
    --local min, max = slider:GetMinMaxValues()
    --print('  slider min='.. min ..' max='.. max ..' value='.. value)
    slider:SetValue(value)
end




function Xist_UI_ScrollFrame:Redraw()
    local innerHeight = self.scrollChild:GetTotalHeight()
    local visibleHeight = self:GetHeight()
    local obscuredHeight = math.max(0, innerHeight - visibleHeight)

    if obscuredHeight == 0 then
        self.slider:SetMinMaxValues(0, 0)
    else
        self.slider:SetMinMaxValues(0, obscuredHeight)
    end
end


function Xist_UI_ScrollFrame:DebugDump()
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
    DEBUG('ScrollFrame', m1, m2)
end
