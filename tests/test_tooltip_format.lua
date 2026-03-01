-------------------------------------------------------------------------------
-- test_tooltip_format.lua
-- Tests that Tooltip formatting wrappers correctly delegate to ns.Format
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns

-------------------------------------------------------------------------------
-- Stub WoW globals required by Tooltip.lua at load time
-------------------------------------------------------------------------------

local function MakeFrameStub()
    return {
        RegisterEvent = function() end,
        UnregisterEvent = function() end,
        SetScript = function() end,
    }
end

_G.CreateFrame = function()
    return MakeFrameStub()
end

_G.GameTooltip = {
    HookScript = function() end,
    AddLine = function() end,
    Show = function() end,
    GetSpell = function() return nil, nil, nil end,
}

-------------------------------------------------------------------------------
-- Load Format.lua + Tooltip.lua into the shared namespace
-------------------------------------------------------------------------------

local fnFmt, errFmt = loadfile("Presentation/Format.lua")
if not fnFmt then error("Failed to load Presentation/Format.lua: " .. tostring(errFmt)) end
fnFmt("PhDamage", ns)

local fn, err = loadfile("Presentation/Tooltip.lua")
if not fn then error("Failed to load Presentation/Tooltip.lua: " .. tostring(err)) end
fn("PhDamage", ns)

local Tooltip = ns.Tooltip
local Format = ns.Format

-------------------------------------------------------------------------------
-- Tests
-------------------------------------------------------------------------------

describe("Tooltip Wrapper Delegation", function()

    describe("FormatNumber delegates to Format", function()
        it("returns same result as Format.FormatNumber", function()
            assert.are.equal(Format.FormatNumber(nil), Tooltip.FormatNumber(nil))
            assert.are.equal(Format.FormatNumber(0), Tooltip.FormatNumber(0))
            assert.are.equal(Format.FormatNumber(500), Tooltip.FormatNumber(500))
            assert.are.equal(Format.FormatNumber(1500), Tooltip.FormatNumber(1500))
            assert.are.equal(Format.FormatNumber(15000), Tooltip.FormatNumber(15000))
        end)
    end)

    describe("FormatDPS delegates to Format", function()
        it("returns same result as Format.FormatDPS", function()
            assert.are.equal(Format.FormatDPS(nil), Tooltip.FormatDPS(nil))
            assert.are.equal(Format.FormatDPS(0), Tooltip.FormatDPS(0))
            assert.are.equal(Format.FormatDPS(250.7), Tooltip.FormatDPS(250.7))
            assert.are.equal(Format.FormatDPS(10000), Tooltip.FormatDPS(10000))
        end)
    end)

    describe("GetSchoolColor delegates to Format", function()
        it("returns same result as Format.GetSchoolColor", function()
            assert.are.equal(Format.GetSchoolColor(ns.SCHOOL_SHADOW), Tooltip.GetSchoolColor(ns.SCHOOL_SHADOW))
            assert.are.equal(Format.GetSchoolColor(nil), Tooltip.GetSchoolColor(nil))
            assert.are.equal(Format.GetSchoolColor(255), Tooltip.GetSchoolColor(255))
        end)
    end)

    describe("ColorValue delegates to Format", function()
        it("returns same result as Format.ColorValue", function()
            assert.are.equal(Format.ColorValue("500", ns.SCHOOL_FIRE), Tooltip.ColorValue("500", ns.SCHOOL_FIRE))
            assert.are.equal(Format.ColorValue("100", 255), Tooltip.ColorValue("100", 255))
        end)
    end)
end)
