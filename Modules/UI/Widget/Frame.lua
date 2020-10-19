
local ModuleName = "Xist_UI_Widget_Frame"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Widget_Frame, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Widget_Frame
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Widget_Frame
Xist_UI_Widget_Frame = M


local inheritance = {Xist_UI_Widget_Frame}

local settings = {}

local classes = {}


Xist_UI_Config:RegisterWidget('frame', inheritance, settings, classes)
