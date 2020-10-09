
local ModuleName = "Xist_UI"
local ModuleVersion = 1

-- If some other addon installed Xist_UI, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI
local StdUi = LibStub("StdUi"):NewInstance()

StdUi.config = {
    font = {
        family    = "Fonts\\FRIZQT__.ttf",
        size      = 12,
        titleSize = 16,
        effect    = 'NONE',
        strata    = 'OVERLAY',
        color     = {
            normal   = { r = 1, g = 1, b = 1, a = 1 },
            disabled = { r = 0.55, g = 0.55, b = 0.55, a = 1 },
            header   = { r = 1, g = 0.9, b = 0, a = 1 },
        },
    },

    fontClasses = {
        messages = {
            size = 12,
            justifyH = 'LEFT',
        },
    },

    backdrop = {
        texture        = [[Interface\Buttons\WHITE8X8]],
        panel          = { r = 0, g = 0.05, b = 0, a = 0.95 },
        slider         = { r = 0.15, g = 0.15, b = 0.15, a = 1 },
        messages       = { r = 0.15, g = 0.15, b = 0.15, a = 1 },

        highlight      = { r = 0.40, g = 0.40, b = 0, a = 0.5 },
        button         = { r = 0.20, g = 0.20, b = 0.20, a = 1 },
        buttonDisabled = { r = 0.15, g = 0.15, b = 0.15, a = 1 },

        border         = { r = 0.00, g = 0.00, b = 0.00, a = 1 },
        borderDisabled = { r = 0.40, g = 0.40, b = 0.40, a = 1 },
    },

    progressBar = {
        color = { r = 1, g = 0.9, b = 0, a = 0.5 },
    },

    highlight = {
        color = { r = 1, g = 0.9, b = 0, a = 0.4 },
        blank = { r = 0, g = 0, b = 0, a = 0 },
    },

    dialog = {
        width  = 400,
        height = 100,
        button = {
            width  = 100,
            height = 20,
            margin = 5,
        }
    },

    tooltip = {
        padding = 10,
    },
}

--- @class Xist_UI
Xist_UI = Xist_Module.Install(ModuleName, ModuleVersion, StdUi)


-- Initialize Xist_UI_Context
local StdContextUi = LibStub("StdUi"):NewInstance()

local contextMenuOverrides = {
    font = {
        color = {
            normal = { r = 0.8, g = 0.8, b = 0.8, a = 1 },
        },
    },
    backdrop = {
        panel = { r = 0, g = 0, b = 0.05, a = 0.95 },
    },
}

StdContextUi.config = Xist_Util.ApplyConfigOverrides(StdUi.config, contextMenuOverrides)

--- @class Xist_UI_Context
Xist_UI_Context = Xist_Module.Install(ModuleName.."_Context", ModuleVersion, StdContextUi)
