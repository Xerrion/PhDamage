-------------------------------------------------------------------------------
-- RunBusted.lua
-- Repo-local Busted launcher that bootstraps LuaRocks paths for the active Lua
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary, Cata, Classic
-------------------------------------------------------------------------------

local io = io
local package = package
local table = table

local ACTIVE_LUA_VERSION = (_VERSION and _VERSION:match("(%d+%.%d+)"))
    or error("Could not detect active Lua version", 0)

local function Trim(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function ReadFirstLine(command)
    local handle = io.popen(command)
    if not handle then
        return nil, "Failed to start command: " .. command
    end

    local output = handle:read("*a") or ""
    local ok, _, code = handle:close()
    local firstLine = Trim((output:match("([^\r\n]+)") or ""))

    if firstLine == "" then
        if ok or code == 0 then
            return nil, "Command returned no output: " .. command
        end

        return nil, "Command failed: " .. command
    end

    return firstLine
end

local function PrependPath(currentValue, entries)
    return table.concat(entries, ";") .. ";" .. currentValue
end

local function BootstrapLuaRocksPaths()
    local runnerPath, runnerErr = ReadFirstLine(
        "luarocks --lua-version " .. ACTIVE_LUA_VERSION .. " which busted.runner"
    )
    if not runnerPath then
        return nil, runnerErr
    end

    runnerPath = runnerPath:gsub("\\", "/")

    local rocksRoot, luaVersion = runnerPath:match("^(.*)/share/lua/(%d+%.%d+)/busted/runner%.lua$")
    if not rocksRoot then
        return nil, "Could not derive LuaRocks tree from: " .. runnerPath
    end

    if luaVersion ~= ACTIVE_LUA_VERSION then
        return nil, "LuaRocks resolved busted for Lua " .. luaVersion
            .. " but active lua is " .. ACTIVE_LUA_VERSION
    end

    package.path = PrependPath(package.path, {
        rocksRoot .. "/share/lua/" .. luaVersion .. "/?.lua",
        rocksRoot .. "/share/lua/" .. luaVersion .. "/?/init.lua",
    })

    package.cpath = PrependPath(package.cpath, {
        rocksRoot .. "/lib/lua/" .. luaVersion .. "/?.dll",
        rocksRoot .. "/lib/lua/" .. luaVersion .. "/?.so",
    })

    return true
end

local function RunBusted()
    local ok, runner = pcall(require, "busted.runner")
    if ok then
        return runner({ standalone = false })
    end

    local originalError = runner
    local _, bootstrapErr = BootstrapLuaRocksPaths()
    if bootstrapErr then
        error("Failed to load busted.runner. Original error: " .. tostring(originalError)
            .. " | Bootstrap error: " .. tostring(bootstrapErr), 0)
    end

    ok, runner = pcall(require, "busted.runner")
    if not ok then
        error("Failed to load busted.runner after LuaRocks bootstrap: " .. tostring(runner), 0)
    end

    return runner({ standalone = false })
end

RunBusted()
