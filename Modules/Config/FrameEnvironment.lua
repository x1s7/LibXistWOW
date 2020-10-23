
local ModuleName = "Xist_Config_FrameEnvironment"
local ModuleVersion = 1

-- If some other addon installed Xist_Config_FrameEnvironment, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_Config_FrameEnvironment
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_Config_FrameEnvironment
Xist_Config_FrameEnvironment = M

--protected.DebugEnabled = true

local DEBUG = protected.DEBUG


function Xist_Config_FrameEnvironment:New(frame)
    local obj = {
        frame = frame,
        runtimeCache = {},
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
        frameId = frameId ..'.'.. class
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


local spaceEquivs = {
    top = 'v',
    bottom = 'v',
    vbetween = 'v',
    left = 'h',
    right = 'h',
    hbetween = 'h',
}

local spaceKeys = {}
for key,_ in pairs(spaceEquivs) do
    spaceKeys[1+#spaceKeys] = key
end


local function buildSpaceConfig(env, envName)
    local spacing = env.runtimeCache[envName]
    if not spacing then
        spacing = env:GetEnv(envName)
        local orig = spacing
        if type(spacing) == 'number' then
            -- They've defined spacing as a number, so use this value for all of the
            -- spacing keys equally.
            local tmp = {}
            for i=1, #spaceKeys do
                tmp[spaceKeys[i]] = spacing
            end
            spacing = tmp
        else
            -- If they've defined spacing as anything other than a number or a table, then
            -- discard it and reset it as an empty table.
            if type(spacing) ~= 'table' then
                spacing = {}
            end
            -- Assign each value of the spacing keys.
            -- If the user defined the key explicitly, use that value.
            -- Otherwise look for the spaceEquivs value
            --   ('v' sets 'top', 'bottom', 'vbetween')
            --   ('h' sets 'left', 'right', 'hbetween')
            -- Default 0 if no configuration is found.
            local key, value
            for i=1, #spaceKeys do
                key = spaceKeys[i]
                if spacing[key] == nil then
                    value = spacing[spaceEquivs[key]]
                    spacing[key] = value or 0
                end
            end
        end
        -- Cache this runtime computed fully-formed spacing config
        env.runtimeCache[envName] = spacing
        DEBUG('Environment', envName, 'COMPUTED', env:GetEnv('frameIdentification'), spacing, 'orig=', orig)
    else
        DEBUG('Environment', envName, 'cached', env:GetEnv('frameIdentification'), spacing)
    end
    return Xist_Util.Copy(spacing)
end


function Xist_Config_FrameEnvironment:GetPadding()
    return buildSpaceConfig(self, 'padding')
end


function Xist_Config_FrameEnvironment:GetSpacing()
    return buildSpaceConfig(self, 'spacing')
end
