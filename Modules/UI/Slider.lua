
local ModuleName = "Xist_UI_Slider"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Slider, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Slider
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Slider
Xist_UI_Slider = M


function Xist_UI_Slider:InitializeSliderWidget()
    self.min = 0
    self.max = 0
    self.step = 0
    self.value = 0

    self.eventHandler = Xist_EventHandler:NewSliderHandler()
end


function Xist_UI_Slider:RegisterEvent(eventName, callback)
    self.eventHandler:RegisterEvent(eventName, callback)
end


function Xist_UI_Slider:GetMinMaxValues()
    return self.min, self.max
end


function Xist_UI_Slider:SetMinMaxValues(min, max)
    self.min = min
    self.max = max
end


function Xist_UI_Slider:GetMinValue()
    return self.min
end


function Xist_UI_Slider:SetMinValue(min)
    self.min = min
end


function Xist_UI_Slider:GetMaxValue()
    return self.max
end


function Xist_UI_Slider:SetMaxValue(max)
    self.max = max
end


function Xist_UI_Slider:GetValue()
    return self.value
end


function Xist_UI_Slider:SetValue(value)
    value = math.max(self.min, math.min(self.max, value)) -- clamp value to min/max
    if value ~= self.value then
        local delta = value - self.value
        self.value = value
        self.eventHandler:TriggerEvent('OnValueChanged', value, delta)
    end
end


function Xist_UI_Slider:GetValueStep()
    return self.step
end


function Xist_UI_Slider:SetValueStep(step)
    self.step = step
end


function Xist_UI_Slider:ScrollToBegin()
    self:SetValue(self.min)
end


function Xist_UI_Slider:ScrollToEnd()
    self:SetValue(self.max)
end


function Xist_UI_Slider:IsScrolledToBegin()
    return self.value == self.min
end


function Xist_UI_Slider:IsScrolledToEnd()
    return self.value == self.max
end
