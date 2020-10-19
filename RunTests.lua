
Xist_CONSOLE_UNIT_TEST = true


local MockFiles = {
    'WOWAPI',
}

local CoreFiles = {
    'Util',
    'Log',
    'Module',
}

local CoreModules = {
    'Config',
    'Config/Namespace',
    'EventHandler',
    'Version',
}

local Modules = {
    'Addon',
    'AddonButton',
    'FriendsList',
    'GameState',
    'Queue',
    'SaveData',
}

local UnitTestFramework = {
    'UnitTestFramework',
    'UnitTest',
}

local UnitTests = {
    'Core/Util',
    'Modules/Config',
    'Modules/Config/Namespace',
    'Modules/Queue',
    'Modules/Version',
}


local BaseDirectory = arg[1] or error('Usage: RunTests.lua /path/to/base/dir')
local specificTest = arg[2] -- possibly nil

local function RequireFile(directory, file)
    local filename = BaseDirectory ..'/'.. directory ..'/'.. file ..'.lua'
    local include = assert(loadfile(filename))
    include()
end

local function RequireFiles(directory, files)
    for i = 1, #files do
        RequireFile(directory, files[i])
    end
end

RequireFiles('Mock', MockFiles)

RequireFiles('Core', CoreFiles)
RequireFiles('Modules', CoreModules)
RequireFiles('Modules', Modules)
RequireFiles('Modules', UnitTestFramework)

if specificTest then
    RequireFile('Tests', specificTest)
else
    RequireFiles('Tests', UnitTests)
end

Xist_UnitTestFramework:Run()
