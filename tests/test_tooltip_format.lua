-------------------------------------------------------------------------------
-- test_tooltip_format.lua
-- Unit tests for PhDamage Tooltip formatting helpers
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns

-------------------------------------------------------------------------------
-- Stub WoW globals required by Tooltip.lua at load time
-------------------------------------------------------------------------------

-- Minimal frame stub for CreateFrame("Frame")
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

-- Minimal GameTooltip stub
_G.GameTooltip = {
    HookScript = function() end,
    AddLine = function() end,
    Show = function() end,
    GetSpell = function() return nil, nil, nil end,
}

-------------------------------------------------------------------------------
-- Load Tooltip.lua into the shared namespace
-------------------------------------------------------------------------------

local fn, err = loadfile("Presentation/Tooltip.lua")
if not fn then error("Failed to load Presentation/Tooltip.lua: " .. tostring(err)) end
fn("PhDamage", ns)

local Tooltip = ns.Tooltip

-------------------------------------------------------------------------------
-- Tests
-------------------------------------------------------------------------------

describe("Tooltip Formatting", function()

    describe("FormatNumber", function()
        it("returns '?' for nil", function()
            assert.are.equal("?", Tooltip.FormatNumber(nil))
        end)

        it("returns '0' for 0", function()
            assert.are.equal("0", Tooltip.FormatNumber(0))
        end)

        it("returns '1' for 1", function()
            assert.are.equal("1", Tooltip.FormatNumber(1))
        end)

        it("returns '500' for 500", function()
            assert.are.equal("500", Tooltip.FormatNumber(500))
        end)

        it("returns '999' for 999", function()
            assert.are.equal("999", Tooltip.FormatNumber(999))
        end)

        it("returns '1.0k' for 1000", function()
            assert.are.equal("1.0k", Tooltip.FormatNumber(1000))
        end)

        it("returns '1.5k' for 1500", function()
            assert.are.equal("1.5k", Tooltip.FormatNumber(1500))
        end)

        it("returns '10.0k' for 9999 (rounds)", function()
            assert.are.equal("10.0k", Tooltip.FormatNumber(9999))
        end)

        it("returns '10k' for 10000", function()
            assert.are.equal("10k", Tooltip.FormatNumber(10000))
        end)

        it("returns '15k' for 15000", function()
            assert.are.equal("15k", Tooltip.FormatNumber(15000))
        end)

        it("returns '100k' for 100000", function()
            assert.are.equal("100k", Tooltip.FormatNumber(100000))
        end)

        it("returns '0' for 0.4 (floors to 0)", function()
            assert.are.equal("0", Tooltip.FormatNumber(0.4))
        end)

        it("returns '1' for 0.6 (rounds up)", function()
            assert.are.equal("1", Tooltip.FormatNumber(0.6))
        end)

        it("returns '1000' for 999.5 (rounds to 1000)", function()
            assert.are.equal("1000", Tooltip.FormatNumber(999.5))
        end)
    end)

    describe("FormatDPS", function()
        it("returns '?' for nil", function()
            assert.are.equal("?", Tooltip.FormatDPS(nil))
        end)

        it("returns '0.0' for 0", function()
            assert.are.equal("0.0", Tooltip.FormatDPS(0))
        end)

        it("returns '1.0' for 1", function()
            assert.are.equal("1.0", Tooltip.FormatDPS(1))
        end)

        it("returns '250.7' for 250.7", function()
            assert.are.equal("250.7", Tooltip.FormatDPS(250.7))
        end)

        it("returns '999.9' for 999.9", function()
            assert.are.equal("999.9", Tooltip.FormatDPS(999.9))
        end)

        it("returns '1.0k' for 1000", function()
            assert.are.equal("1.0k", Tooltip.FormatDPS(1000))
        end)

        it("returns '1.5k' for 1500", function()
            assert.are.equal("1.5k", Tooltip.FormatDPS(1500))
        end)

        it("returns '10k' for 10000", function()
            assert.are.equal("10k", Tooltip.FormatDPS(10000))
        end)
    end)

    describe("GetSchoolColor", function()
        it("returns correct color for Shadow", function()
            assert.are.equal("|cff9b59b6", Tooltip.GetSchoolColor(ns.SCHOOL_SHADOW))
        end)

        it("returns correct color for Fire", function()
            assert.are.equal("|cffe74c3c", Tooltip.GetSchoolColor(ns.SCHOOL_FIRE))
        end)

        it("returns correct color for Holy", function()
            assert.are.equal("|cfff1c40f", Tooltip.GetSchoolColor(ns.SCHOOL_HOLY))
        end)

        it("returns correct color for Nature", function()
            assert.are.equal("|cff2ecc71", Tooltip.GetSchoolColor(ns.SCHOOL_NATURE))
        end)

        it("returns correct color for Frost", function()
            assert.are.equal("|cff3498db", Tooltip.GetSchoolColor(ns.SCHOOL_FROST))
        end)

        it("returns correct color for Arcane", function()
            assert.are.equal("|cff1abc9c", Tooltip.GetSchoolColor(ns.SCHOOL_ARCANE))
        end)

        it("returns correct color for Physical", function()
            assert.are.equal("|cffbdc3c7", Tooltip.GetSchoolColor(ns.SCHOOL_PHYSICAL))
        end)

        it("returns white fallback for unknown school (255)", function()
            assert.are.equal("|cffffffff", Tooltip.GetSchoolColor(255))
        end)

        it("returns white fallback for nil", function()
            assert.are.equal("|cffffffff", Tooltip.GetSchoolColor(nil))
        end)
    end)

    describe("ColorValue", function()
        it("wraps text with school color and reset code", function()
            local result = Tooltip.ColorValue("500", ns.SCHOOL_SHADOW)
            assert.are.equal("|cff9b59b6500|r", result)
        end)

        it("wraps text with Fire school color", function()
            local result = Tooltip.ColorValue("1.5k", ns.SCHOOL_FIRE)
            assert.are.equal("|cffe74c3c1.5k|r", result)
        end)

        it("wraps text with Frost school color", function()
            local result = Tooltip.ColorValue("250", ns.SCHOOL_FROST)
            assert.are.equal("|cff3498db250|r", result)
        end)

        it("falls back to white for unknown school", function()
            local result = Tooltip.ColorValue("100", 255)
            assert.are.equal("|cffffffff100|r", result)
        end)
    end)
end)
