
local ModuleName = "Xist_UI_Font"
local ModuleVersion = 1

-- If some other addon installed Xist_UI_Font, don't do it again
if not Xist_Module.NeedsUpgrade(ModuleName, ModuleVersion) then return end

-- Initialize Xist_UI_Font
local M, protected = Xist_Module.Install(ModuleName, ModuleVersion)

--- @class Xist_UI_Font
Xist_UI_Font = M


function Xist_UI_Font:GetFontHeight()
    local _, height = self:GetFont()
    return height
end
