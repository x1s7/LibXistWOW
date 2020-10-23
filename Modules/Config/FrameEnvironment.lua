
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
    local parent = Xist_UI:GetParentWidget(self.frame)
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
    -- if this frame has a name, display the name
    local name = self.frame:GetName()
    if name then
        frameId = frameId .. name
    else
        -- this frame has no name, add a description of what it is (type:class)
        frameId = frameId .. (self.frame.widgetType or 'UNKNOWN')
        local class = self.frame.widgetClass or 'UNKNOWN'
        frameId = frameId ..':'.. class
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


function Xist_Config_FrameEnvironment:GetEnv(name, default)
    local env = self:GetEnvironment()
    if env[name] == nil then
        return default -- possibly nil
    end
    return env[name]
end


function Xist_Config_FrameEnvironment:GetPadding()
    local padding = self:GetEnv('padding')
    if not padding then
        padding = {
            top = self:GetEnv('topPadding', 0),
            left = self:GetEnv('leftPadding', 0),
            bottom = self:GetEnv('bottomPadding', 0),
            right = self:GetEnv('rightPadding', 0),
        }
    end
    return padding
end
