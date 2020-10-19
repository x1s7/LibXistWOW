
local ModuleName = "Xist_Config_FrameEnvironment"
local ModuleVersion = 1

-- If some other addon installed Xist_Config_FrameEnvironment, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Config_FrameEnvironment
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_Config_FrameEnvironment
Xist_Config_FrameEnvironment = M

protected.DebugEnabled = true

local DEBUG = protected.DEBUG


function Xist_Config_FrameEnvironment:New(frame)
    local obj = {
        frame = frame,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end


function Xist_Config_FrameEnvironment:GetParentEnvironment()
    local env = {}
    local parent = self.frame:GetParentWidget()
    if parent then
        -- there is a parent widget
        if parent.GetWidgetEnvironment then
            -- the parent is a widget with an environment; copy the environment
            local ENV = parent:GetWidgetEnvironment()
            env = ENV:GetEnvironment()
        end
        if not env.frameIdentification then
            -- the parent hasn't defined a frameIdentification, so supply a suitable default
            env.frameIdentification = parent:GetName() or 'UNDEFINED_NAME'
        end
    end
    return env
end


function Xist_Config_FrameEnvironment:GetFrameIdentification(parentFrameIdentification)
    -- preserve the parent frameId
    local frameId = parentFrameIdentification or ''
    if frameId ~= '' then
        frameId = frameId ..'/'
    end
    -- add widgetType `parent/type)'
    frameId = frameId .. self.frame.widgetType
    -- optionally add widgetClass `parent/type:class'
    local class = self.frame.widgetClass
    if class then
        frameId = frameId ..':'.. class
    end
    -- optionally add name `parent/type:class(name)'
    local name = self.frame:GetName()
    if name then
        frameId = frameId ..'('.. name ..')'
    end
    return frameId
end


function Xist_Config_FrameEnvironment:GetEnvironment()
    if not self.env then
        local env = self:GetParentEnvironment()
        local id = self:GetFrameIdentification(env.frameIdentification)
        -- now apply the widget's config as an override to the environment
        local conf = self.frame:GetWidgetConfig()
        Xist_Config:ApplyNestedOverrides(env, conf)
        -- apply the id (don't allow it to change)
        env.frameIdentification = id
        self.env = env
    end
    return Xist_Util.Copy(self.env)
end
