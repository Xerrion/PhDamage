-------------------------------------------------------------------------------
-- test_spell_resolver.lua
-- Verifies ns.SpellResolver correctly maps every known spell ID variant
-- (base, per-rank cast, per-rank effect) to the right (baseID, rankIndex)
-- pair. Regression coverage for issue #44 / Phase 5: Hellfire R4 channel
-- cast ID 27213 must resolve, not just effect ID 27214.
--
-- Contract for the base-ID-only case: when SpellData[baseID].ranks[1].spellID
-- equals baseID (the common Wowhead convention - true for Hellfire), Resolve
-- returns rankIndex = 1. This is consistent with how an actual rank-1 cast
-- ID resolves, since they collide on the same key.
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

require("busted.runner")()

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns

describe("SpellResolver", function()

    before_each(function()
        -- Ensure a clean lookup state for tests that exercise Rebuild()
        ns.SpellResolver.Rebuild()
    end)

    it("resolves base ID to itself with rank 1 (rank 1 spellID == base)", function()
        local baseID, rankIndex = ns.SpellResolver.Resolve(1949)
        assert.are.equal(1949, baseID)
        assert.are.equal(1, rankIndex)
    end)

    it("resolves rank 1 cast ID to base + rank 1", function()
        local baseID, rankIndex = ns.SpellResolver.Resolve(1949)
        assert.are.equal(1949, baseID)
        assert.are.equal(1, rankIndex)
    end)

    it("resolves rank 2 cast ID to base + rank 2", function()
        local baseID, rankIndex = ns.SpellResolver.Resolve(11683)
        assert.are.equal(1949, baseID)
        assert.are.equal(2, rankIndex)
    end)

    it("resolves rank 3 cast ID to base + rank 3", function()
        local baseID, rankIndex = ns.SpellResolver.Resolve(11684)
        assert.are.equal(1949, baseID)
        assert.are.equal(3, rankIndex)
    end)

    it("resolves rank 4 cast ID 27213 (the bug) to base + rank 4", function()
        local baseID, rankIndex = ns.SpellResolver.Resolve(27213)
        assert.are.equal(1949, baseID)
        assert.are.equal(4, rankIndex)
    end)

    it("resolves rank 4 effect ID 27214 to same base + rank 4", function()
        local baseID, rankIndex = ns.SpellResolver.Resolve(27214)
        assert.are.equal(1949, baseID)
        assert.are.equal(4, rankIndex)
    end)

    it("resolves rank 1 effect ID 5857 to base + rank 1", function()
        local baseID, rankIndex = ns.SpellResolver.Resolve(5857)
        assert.are.equal(1949, baseID)
        assert.are.equal(1, rankIndex)
    end)

    it("resolves rank 2 effect ID 11681 to base + rank 2", function()
        local baseID, rankIndex = ns.SpellResolver.Resolve(11681)
        assert.are.equal(1949, baseID)
        assert.are.equal(2, rankIndex)
    end)

    it("resolves rank 3 effect ID 11682 to base + rank 3", function()
        local baseID, rankIndex = ns.SpellResolver.Resolve(11682)
        assert.are.equal(1949, baseID)
        assert.are.equal(3, rankIndex)
    end)

    it("returns nil for unknown spell ID", function()
        local baseID, rankIndex = ns.SpellResolver.Resolve(999999)
        assert.is_nil(baseID)
        assert.is_nil(rankIndex)
    end)

    it("returns nil for non-numeric input", function()
        local baseID, rankIndex = ns.SpellResolver.Resolve("not a number")
        assert.is_nil(baseID)
        assert.is_nil(rankIndex)
    end)

    it("returns nil for nil input", function()
        local baseID, rankIndex = ns.SpellResolver.Resolve(nil)
        assert.is_nil(baseID)
        assert.is_nil(rankIndex)
    end)

    it("Rebuild clears and reloads lookup", function()
        local baseBefore, rankBefore = ns.SpellResolver.Resolve(1949)
        ns.SpellResolver.Rebuild()
        local baseAfter, rankAfter = ns.SpellResolver.Resolve(1949)
        assert.are.equal(baseBefore, baseAfter)
        assert.are.equal(rankBefore, rankAfter)
    end)
end)
