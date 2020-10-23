
local ModuleName = "Xist_UI_Widget_Texture"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Texture, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Texture
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Texture
Xist_UI_Widget_Texture = M


local DEFAULT_ALPHA_MODE = 'BLEND'
local DEFAULT_LAYER = 'BACKGROUND'

local inheritance = {Xist_UI_Widget_Texture}

local settings = {
}

local classes = {
    default = {
        textureAlphaMode = DEFAULT_ALPHA_MODE,
        textureLayer = DEFAULT_LAYER,
    },
    buttonHighlight = {
        textureColor = { r=0.8, g=0.8, b=0, a=1 },
    },
    buttonNormal = {
        textureColor = { r=0.3, g=0, b=0, a=1 },
    },
    buttonPushed = {
        textureAlphaMode = 'ADD',
        textureColor = { r=0, g=0.3, b=0, a=1 },
    },
    buttonTransparent = {
        textureColor = { r=0.15, g=0.15, b=0.15, a=1 },
    },
    slider = {
        textureFile = [[Interface\Buttons\UI-SliderBar-Button-Vertical]],
        textureWidth = 32,
        textureHeight = 32,
    },
}


local function InitTexture(widget)
    local env = widget:GetWidgetEnvironment()

    --DEBUG('InitTexture class=', widget.widgetClass, 'env=', env:GetEnvironment())

    widget:SetAllPoints() -- occupy entire space of parent frame

    local layer = env:GetEnv('textureLayer', DEFAULT_LAYER)
    widget:SetDrawLayer(layer)

    local alphaMode = env:GetEnv('textureAlphaMode', DEFAULT_ALPHA_MODE)
    widget:SetBlendMode(alphaMode)

    local textureFile = env:GetEnv('textureFile')
    if textureFile then
        widget:SetTexture(textureFile)
    end

    local c = env:GetEnv('textureColor')
    if c then
        widget:SetColorTexture(c.r, c.g, c.b, c.a)
    end
end


Xist_UI_Config:RegisterWidget('texture', inheritance, settings, classes, InitTexture)
