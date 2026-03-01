-------------------------------------------------------------------------------
-- test_format.lua
-- Unit tests for the shared Format module (Presentation/Format.lua)
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns

-------------------------------------------------------------------------------
-- Load Format.lua into the shared namespace
-------------------------------------------------------------------------------

local fn, err = loadfile("Presentation/Format.lua")
if not fn then error("Failed to load Presentation/Format.lua: " .. tostring(err)) end
fn("PhDamage", ns)

local Format = ns.Format

-------------------------------------------------------------------------------
-- Tests
-------------------------------------------------------------------------------

describe("Format Module", function()

    describe("FormatNumber", function()
        it("returns '?' for nil", function()
            assert.are.equal("?", Format.FormatNumber(nil))
        end)

        it("returns '0' for 0", function()
            assert.are.equal("0", Format.FormatNumber(0))
        end)

        it("returns '1' for 1", function()
            assert.are.equal("1", Format.FormatNumber(1))
        end)

        it("returns '500' for 500", function()
            assert.are.equal("500", Format.FormatNumber(500))
        end)

        it("returns '999' for 999", function()
            assert.are.equal("999", Format.FormatNumber(999))
        end)

        it("returns '1.0k' for 1000", function()
            assert.are.equal("1.0k", Format.FormatNumber(1000))
        end)

        it("returns '1.5k' for 1500", function()
            assert.are.equal("1.5k", Format.FormatNumber(1500))
        end)

        it("returns '10.0k' for 9999 (rounds)", function()
            assert.are.equal("10.0k", Format.FormatNumber(9999))
        end)

        it("returns '10k' for 10000", function()
            assert.are.equal("10k", Format.FormatNumber(10000))
        end)

        it("returns '15k' for 15000", function()
            assert.are.equal("15k", Format.FormatNumber(15000))
        end)

        it("returns '100k' for 100000", function()
            assert.are.equal("100k", Format.FormatNumber(100000))
        end)

        it("returns '0' for 0.4 (floors to 0)", function()
            assert.are.equal("0", Format.FormatNumber(0.4))
        end)

        it("returns '1' for 0.6 (rounds up)", function()
            assert.are.equal("1", Format.FormatNumber(0.6))
        end)
    end)

    describe("FormatDPS", function()
        it("returns '?' for nil", function()
            assert.are.equal("?", Format.FormatDPS(nil))
        end)

        it("returns '0.0' for 0", function()
            assert.are.equal("0.0", Format.FormatDPS(0))
        end)

        it("returns '1.0' for 1", function()
            assert.are.equal("1.0", Format.FormatDPS(1))
        end)

        it("returns '250.7' for 250.7", function()
            assert.are.equal("250.7", Format.FormatDPS(250.7))
        end)

        it("returns '999.9' for 999.9", function()
            assert.are.equal("999.9", Format.FormatDPS(999.9))
        end)

        it("returns '1.0k' for 1000", function()
            assert.are.equal("1.0k", Format.FormatDPS(1000))
        end)

        it("returns '1.5k' for 1500", function()
            assert.are.equal("1.5k", Format.FormatDPS(1500))
        end)

        it("returns '10k' for 10000", function()
            assert.are.equal("10k", Format.FormatDPS(10000))
        end)
    end)

    describe("GetSchoolColor", function()
        it("returns correct color for Shadow", function()
            assert.are.equal("|cff9b59b6", Format.GetSchoolColor(ns.SCHOOL_SHADOW))
        end)

        it("returns correct color for Fire", function()
            assert.are.equal("|cffe74c3c", Format.GetSchoolColor(ns.SCHOOL_FIRE))
        end)

        it("returns correct color for Holy", function()
            assert.are.equal("|cfff1c40f", Format.GetSchoolColor(ns.SCHOOL_HOLY))
        end)

        it("returns correct color for Nature", function()
            assert.are.equal("|cff2ecc71", Format.GetSchoolColor(ns.SCHOOL_NATURE))
        end)

        it("returns correct color for Frost", function()
            assert.are.equal("|cff3498db", Format.GetSchoolColor(ns.SCHOOL_FROST))
        end)

        it("returns correct color for Arcane", function()
            assert.are.equal("|cff1abc9c", Format.GetSchoolColor(ns.SCHOOL_ARCANE))
        end)

        it("returns correct color for Physical", function()
            assert.are.equal("|cffbdc3c7", Format.GetSchoolColor(ns.SCHOOL_PHYSICAL))
        end)

        it("returns white fallback for unknown school (255)", function()
            assert.are.equal("|cffffffff", Format.GetSchoolColor(255))
        end)

        it("returns white fallback for nil", function()
            assert.are.equal("|cffffffff", Format.GetSchoolColor(nil))
        end)
    end)

    describe("ColorValue", function()
        it("wraps text with Shadow school color", function()
            assert.are.equal("|cff9b59b6500|r", Format.ColorValue("500", ns.SCHOOL_SHADOW))
        end)

        it("wraps text with Fire school color", function()
            assert.are.equal("|cffe74c3c1.5k|r", Format.ColorValue("1.5k", ns.SCHOOL_FIRE))
        end)

        it("wraps text with Frost school color", function()
            assert.are.equal("|cff3498db250|r", Format.ColorValue("250", ns.SCHOOL_FROST))
        end)

        it("falls back to white for unknown school", function()
            assert.are.equal("|cffffffff100|r", Format.ColorValue("100", 255))
        end)
    end)

    describe("Symbol Constants", function()
        it("MULTIPLY is ASCII 'x'", function()
            assert.are.equal("x", Format.MULTIPLY)
        end)

        it("ARROW is ASCII '->'", function()
            assert.are.equal("->", Format.ARROW)
        end)

        it("BULLET is ASCII '-'", function()
            assert.are.equal("-", Format.BULLET)
        end)
    end)

    describe("Color Constants", function()
        it("COLOR_GOLD starts with |cff", function()
            assert.truthy(Format.COLOR_GOLD:match("^|cff"))
        end)

        it("COLOR_GREEN is green", function()
            assert.are.equal("|cff00ff00", Format.COLOR_GREEN)
        end)

        it("COLOR_WHITE is white", function()
            assert.are.equal("|cffffffff", Format.COLOR_WHITE)
        end)

        it("COLOR_LABEL starts with |cff", function()
            assert.truthy(Format.COLOR_LABEL:match("^|cff"))
        end)

        it("COLOR_RESET is |r", function()
            assert.are.equal("|r", Format.COLOR_RESET)
        end)
    end)
end)
