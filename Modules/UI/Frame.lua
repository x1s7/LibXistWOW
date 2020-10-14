
local ModuleName = "Xist_UI_Frame"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Frame, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Frame
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Frame
Xist_UI_Frame = M

