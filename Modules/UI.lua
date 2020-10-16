
local ModuleName = "Xist_UI"
local ModuleVersion = 1

-- If some other addon installed Xist_UI, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI
Xist_UI = M

protected.DebugEnabled = true

local DEBUG = protected.DEBUG
local WARNING = protected.WARNING

-- a full screen frame to be the parent of all Xist_UI elements
-- this way we can easily hide them all in combat, for example
local TopLevelFrame = CreateFrame('Frame', nil, UIParent)
TopLevelFrame:SetPoint('TOPLEFT')
TopLevelFrame:SetPoint('BOTTOMRIGHT')
TopLevelFrame:Show()
Xist_UI.UIParent = TopLevelFrame

local DEFAULT_CONFIG = Xist_Config:New({

    fontClasses = {
        default = {
            family = [[Fonts\FRIZQT__.ttf]],
            size = 12,
            flags = '', -- OUTLINE,THICKOUTLINE,MONOCHROME
            justifyH = 'CENTER',
            justifyV = 'MIDDLE',
            color = {
                default = { r=1, g=1, b=1, a=1 },
                disabled = { r=0.6, g=0.6, b=0.6, a=1 },
                highlight = { r=1, g=1, b=0, a=1 },
            },
        },
        button = {
            color = {
                default = { r=0, g=1, b=0, a=1 },
            },
        },
        contextMenu = {
            color = {
                default = { r=0.8, g=0.8, b=0, a=1 },
            },
        },
        messages = {
            justifyH = 'LEFT',
        },
        title = {
            size = 16,
            flags = 'OUTLINE',
            color = {
                default = { r=1, g=1, b=0, a=1 },
            },
        },
        contextMenuTitle = {
            size = 14,
            color = {
                default = { r=1, g=1, b=1, a=1 },
            },
        },
    },

    backdropClasses = {
        default = {
            backdrop = {
                bgFile = [[Interface\Buttons\WHITE8X8]],
                edgeFile = [[Interface\Buttons\WHITE8X8]],
                edgeSize = 1,
                tile = false,
                tileSize = 0,
                insets = { left = 0, right = 0, top = 0, bottom = 0 },
            },
            borderColor = { r=1, g=0, b=0, a=0.8 },
            color = { r=0.1, g=0.1, b=0.1, a=0.8 },
        },
        borderless = {
            backdrop = {
                edgeFile = Xist_Config.DELETE,
                edgeSize = 0,
            },
        },
        contextMenu = {
            borderColor = { r=1, g=1, b=0, a=0.8 },
            color = { r=0, g=.05, b=0, a=0.8 },
        },
        transparent = {
            backdrop = {
                bgFile = Xist_Config.DELETE,
                edgeFile = Xist_Config.DELETE,
                edgeSize = 0,
            },
        },
        slider = {
            backdrop = {
                bgFile = [[Interface\Buttons\UI-SliderBar-Background]],
                edgeFile = [[Interface\Buttons\UI-SliderBar-Border]],
                edgeSize = 8,
                tile = true,
                tileSize = 8,
                insets = { left = 3, right = 3, top = 6, bottom = 6 },
            },
        },
    },

    textureClasses = {
        slider = {
            file = [[Interface\Buttons\UI-SliderBar-Button-Vertical]],
            width = 32,
            height = 32,
        },
    },

    buttonClasses = {
        default = {
            backdropClass = 'button',
            fontClass = 'button',
        },
        contextMenu = {
            backdropClass = 'transparent',
            fontClass = 'contextMenu',
        },
    },

    contextMenuClasses = {
        default = {
            backdropClass = 'contextMenu',
            buttonClass = 'contextMenu',
            fontClass = 'contextMenu',
            titleFontClass = 'contextMenuTitle',
        },
    },

    panelClasses = {
        default = {
            backdropClass = 'default',
            buttonClass = 'default',
            fontClass = 'default',
        },
    },

    dialogClasses = {
        default = {
            parent = {'panelClasses', 'default'},
            buttonPadding = 4,
        },
    },

    messageFrameClasses = {
        default = {
            parent = {'panelClasses', 'default'},
            fontClass = 'messages',
            linePadding = 4,
            lineSpacing = 2,
            maxLines = 50,
        },
    },

    scrollFrameClasses = {
        default = {
            topPadding = 0,
            leftPadding = 0,
            bottomPadding = 0,
            rightPadding = 0,
            defaultLineHeight = 12,
        },
    },

    sliderClasses = {
        default = {
            backdropClass = 'slider',
            textureClass = 'slider',
        },
    },

    windowClasses = {
        default = {
            parent = {'dialogClasses', 'default'},
            titleFontClass = 'title',
            titlePadding = 4,
        },
    },

    widgetSettings = {
        button = {
            backdrop = true,
            clampedToScreen = true,
            show = true,
            strata = 'DIALOG',
        },
        contextMenu = {
            parent = 'panel',
            itemPadding = 4,
        },
        fontString = {
            show = true,
        },
        label = {
            show = true,
        },
        panel = {
            backdrop = true,
            clampedToScreen = true,
            height = 200,
            show = true,
            strata = 'DIALOG',
            width = 200,
        },
        fauxScrollFrame = {
            show = true,
        },
        messageFrame = {
            show = true,
        },
        scrollFrame = {
            show = true,
        },
        scrollingMessageFrame = {
            show = true,
            strata = 'DIALOG',
        },
        slider = {
            show = true,
            strata = 'DIALOG',
        },
        window = {
            anchors = {{'CENTER'}},
            parent = 'panel',
        },
    },
})


--- Inherit parent classes into obj.
--- @param obj table
--- @param inheritClasses table[] list of classes
local function InheritParentClasses(obj, inheritClasses)
    inheritClasses = inheritClasses or {Xist_UI_Common}

    local wantCopy
    -- copy methods from class to obj
    for _, class in ipairs(inheritClasses) do
        for k, v in pairs(class) do
            -- we do NOT want to copy _meta information
            wantCopy = k ~= '_meta'
            if wantCopy then
                -- if obj already has a method of this name, classify it as the super,
                -- save a reference to it as _methodName
                if obj[k] and type(obj[k]) == 'function' then
                    obj['_'.. k] = obj[k]
                end
                -- install this class method to obj
                obj[k] = v
            end
        end
    end
end


--- Initialize a widget.
--- @param obj table
--- @param type string
--- @param className string
--- @param config table
--- @param inheritClasses table[]
local function InitializeWidget(obj, type, className, config, inheritClasses)
    -- First inherit from the parent classes
    InheritParentClasses(obj, inheritClasses)

    local parent = obj:GetParent()

    obj.widgetType = type

    -- Here we should determine the default widget class differently
    -- TODO look at the parent's CONFIG to determine the default widget type.

    -- If there is no specific className for this widget, then the default name
    -- is the parent's widgetType, such that buttons on a ContextMenu will be className='contextMenu',
    -- etc.  If there is no parent or it is not a widget, the default is 'default'
    obj.widgetClass = className or (parent and parent.widgetType) or 'default'

    -- If this widget has its own config, initialize it.
    -- Otherwise initialize an empty config accessing the parent's config.
    local parentConfig = parent and parent.config or DEFAULT_CONFIG
    obj.config = Xist_Config:New(config, parentConfig) -- if config is nil, that's ok

    -- apply widget settings
    local settings = obj.config:GetKey({'widgetSettings', type})
    if settings == nil then
        WARNING("Config is missing settings for type", type, "(Define `widgetSettings."..type.."' to silence this warning)")
        return -- there are no widget settings to apply
    end

    -- if this widget derives from another, incorporate the parent's settings
    local tree = {type}
    while settings.parent ~= nil do
        -- remove settings.parent to stop the loop, but first store it in a temporary variable
        local parentSettingsName = settings.parent
        settings.parent = nil
        -- search for the parent settings by name
        local parentSettings = obj.config:GetKey({ 'widgetSettings', parentSettingsName }) or {}
        if parentSettings then
            -- we did indeed find this parent settings, so merge the child settings into it
            tree[#tree+1] = parentSettingsName
            settings = Xist_Config:ApplyNestedOverrides(parentSettings, settings)
        end
        if #tree >= 10 then
            error('Probably recursive widget settings dependencies: '.. Xist_Util.Join(tree, ', '))
        end
    end

    -- Save the settings for later reference
    obj.widgetSettings = settings

    if settings.width ~= nil then
        obj:SetWidth(settings.width)
    end

    if settings.height ~= nil then
        obj:SetHeight(settings.height)
    end

    if settings.clampedToScreen == true then
        obj:SetClampedToScreen(true)
    end

    if settings.strata ~= nil then
        obj:SetFrameStrata(settings.strata)
    end

    if settings.anchors and #settings.anchors then
        for _, anchor in ipairs(settings.anchors) do
            obj:SetPoint(unpack(anchor))
        end
    end

    if settings.backdrop then
        obj:InitializeBackdrop()
    end

    if settings.show then
        obj:Show()
    else
        obj:Hide()
    end
end


--- Create a Font object.
--- Read settings from the config to initialize the object.
--- @param config Xist_Config
--- @param class string
--- @param colorCode string
--- @return Font
function Xist_UI:CreateFont(config, class, colorCode)
    class = class or 'default'
    colorCode = colorCode or 'default'

    local fontClasses = config:GetKey({'fontClasses'})
    local fontConf = fontClasses.default

    if class ~= 'default' and fontClasses[class] ~= nil then
        Xist_Config:ApplyNestedOverrides(fontConf, fontClasses[class])
    end

    -- CreateFont *requires* a globally unique name for this font
    -- We won't ever refer to this by its name but we still need to generate a unique name

    local color = fontConf.color[colorCode] or fontConf.color.default

    local fontFullName = "LibXistWOW Runtime Font "..
            fontConf.family .." ".. fontConf.size .." ".. fontConf.flags ..";"..
            color.r ..",".. color.g ..",".. color.b ..":".. color.a ..";"..
            fontConf.justifyH .."-".. fontConf.justifyV

    local font = CreateFont(fontFullName)
    font:SetFont(fontConf.family, fontConf.size, fontConf.flags)
    font:SetTextColor(color.r, color.g, color.b, color.a)
    font:SetJustifyH(fontConf.justifyH)
    font:SetJustifyV(fontConf.justifyV)

    --print('CreateFont '.. class ..' '.. colorCode ..' JH='.. fontConf.justifyH)

    InheritParentClasses(font, {Xist_UI_Font})

    return font, fontFullName
end


--- Get a font object.
--- This caches the font at runtime so we only have to instantiate each class+colorCode once.
--- @param config Xist_Config
--- @param class string|nil
--- @param colorCode string|nil
--- @return Font
function Xist_UI:GetFontObject(config, class, colorCode)
    class = class or 'default'
    colorCode = colorCode or 'default'

    -- look for a previously cached copy of this font
    local path = {'runtimeFontCache', class, colorCode}
    local font = config:GetKey(path)
    if not font then
        -- generate the font from the config
        font = self:CreateFont(config, class, colorCode)
        -- override the config with this runtime generated font
        -- here we will set it as far up the dependency chain as we can, ignoring all the
        -- low level configs that are empty, to maximize cache hits
        config:SetKeyInLowestNonEmptyNamespace(path, font)
    end
    return font
end


function Xist_UI:MakeWidgetDraggable(widget)
    widget:SetMovable(true)
    widget:EnableMouse(true)
    widget:RegisterForDrag('LeftButton')
    widget:SetScript('OnDragStart', widget.StartMoving)
    widget:SetScript('OnDragStop', widget.StopMovingOrSizing)
end


--- @see https://wowwiki.fandom.com/wiki/UIOBJECT_FontString
function Xist_UI:FontString(parent, className, colorCode, widgetType, config, inheritClasses)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'fontString'
    inheritClasses = inheritClasses or {Xist_UI_Common, Xist_UI_FontString}
    local fontString = parent:CreateFontString(nil)
    InitializeWidget(fontString, widgetType, className, config, inheritClasses)
    fontString:InitializeFontStringWidget(colorCode)
    return fontString
end


function Xist_UI:Frame(parent, className, widgetType, config, inheritClasses)
    parent = parent or Xist_UI.UIParent
    inheritClasses = inheritClasses or {Xist_UI_Common, Xist_UI_Frame}
    local frame = CreateFrame('Frame', nil, parent)
    InitializeWidget(frame, widgetType, className, config, inheritClasses)
    return frame
end


function Xist_UI:Panel(parent, className, widgetType, config, inheritClasses)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'panel'
    local panel = self:Frame(parent, className, widgetType, config, inheritClasses)
    return panel
end


function Xist_UI:MessageFrame(parent, className, widgetType, config, inheritClasses)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'messageFrame'
    inheritClasses = inheritClasses or {Xist_UI_Common, Xist_UI_MessageFrame}
    local panel = self:Panel(parent, className, widgetType, config, inheritClasses)
    panel:InitializeMessageFrameWidget()
    return panel
end


function Xist_UI:Slider(parent, className, widgetType, config, inheritClasses)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'slider'
    inheritClasses = inheritClasses or {Xist_UI_Common, Xist_UI_Slider}
    local slider = CreateFrame('Frame', nil, parent)
    InitializeWidget(slider, widgetType, className, config, inheritClasses)
    slider:InitializeSliderWidget()
    return slider
end


function Xist_UI:FauxScrollFrame(parent, contentFrame, className, widgetType, config, inheritClasses)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'fauxScrollFrame'
    inheritClasses = inheritClasses or {Xist_UI_Common, Xist_UI_FauxScrollFrame}
    local frame = CreateFrame('ScrollFrame', nil, parent, 'FauxScrollFrameTemplate')
    InitializeWidget(frame, widgetType, className, config, inheritClasses)
    frame:InitializeFauxScrollFrameWidget(contentFrame)
    return frame
end


function Xist_UI:ScrollFrame(parent, contentFrame, className, widgetType, config, inheritClasses)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'scrollFrame'
    inheritClasses = inheritClasses or {Xist_UI_Common, Xist_UI_ScrollFrame}
    local frame = CreateFrame('ScrollFrame', nil, parent)
    InitializeWidget(frame, widgetType, className, config, inheritClasses)
    frame:InitializeScrollFrameWidget(contentFrame)
    return frame
end


function Xist_UI:ScrollingMessageFrame(parent, className, widgetType, config, inheritClasses)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'scrollingMessageFrame'
    inheritClasses = inheritClasses or {Xist_UI_Common, Xist_UI_ScrollingMessageFrame}
    local frame = CreateFrame('ScrollingMessageFrame', nil, parent)
    InitializeWidget(frame, widgetType, className, config, inheritClasses)
    frame:InitializeScrollingMessageFrameWidget()
    return frame
end


function Xist_UI:Label(parent, className, colorCode, widgetType, config, inheritClasses)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'label'
    inheritClasses = inheritClasses or {Xist_UI_Common, Xist_UI_Label}
    local label = self:Panel(parent, className, widgetType, config, inheritClasses)
    label:InitializeLabelWidget(colorCode)
    return label
end


function Xist_UI:Button(parent, className, widgetType, config, inheritClasses)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'button'
    inheritClasses = inheritClasses or {Xist_UI_Common, Xist_UI_Button}
    local button = CreateFrame('Button', nil, parent)
    InitializeWidget(button, widgetType, className, config, inheritClasses)
    button:InitializeButtonWidget()
    return button
end


function Xist_UI:ContextMenu(parent, options, className, widgetType, config, inheritClasses)
    parent = parent or Xist_UI.UIParent
    widgetType = widgetType or 'contextMenu'
    inheritClasses = inheritClasses or {Xist_UI_Common, Xist_UI_ContextMenu}
    local menu = self:Panel(parent, className, widgetType, config, inheritClasses)
    menu:InitializeContextMenuWidget(options)
    return menu
end


function Xist_UI:Dialog(parent, className, widgetType, config, inheritClasses)
    widgetType = widgetType or 'dialog'
    inheritClasses = inheritClasses or {Xist_UI_Common, Xist_UI_Dialog}
    local dialog = self:Panel(parent, className, widgetType, config, inheritClasses)
    dialog:InitializeDialogWidget()
    return dialog
end


function Xist_UI:Window(parent, title, className, widgetType, config, inheritClasses)
    widgetType = widgetType or 'window'
    inheritClasses = inheritClasses or {Xist_UI_Common, Xist_UI_Dialog, Xist_UI_Window}
    local win = self:Dialog(parent, className, widgetType, config, inheritClasses)
    win:InitializeWindowWidget(title)
    return win
end
