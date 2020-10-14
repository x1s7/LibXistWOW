
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
    'Config',
    'Queue',
}


local BaseDirectory = arg[1] or error('Usage: RunTests.lua /path/to/base/dir')

local function RequireFiles(directory, files)
    local filename
    for i = 1, #files do
        filename = BaseDirectory ..'/'.. directory ..'/'.. files[i] ..'.lua'
        local f = assert(loadfile(filename))
        f()
    end
end

RequireFiles('Mock', MockFiles)

RequireFiles('Core', CoreFiles)
RequireFiles('Modules', CoreModules)
RequireFiles('Modules', Modules)
RequireFiles('Modules', UnitTestFramework)
RequireFiles('Tests', UnitTests)

Xist_UnitTestFramework:Run()
