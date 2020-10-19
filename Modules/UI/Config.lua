
local ModuleName = "Xist_UI_Config"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Config, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Config
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion, Xist_Config_UI:New())

--- @var Xist_UI_Config
Xist_UI_Config = M
