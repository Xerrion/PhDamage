-------------------------------------------------------------------------------
-- test_aoe_coefficients.lua
-- Pins corrected AoE/Volley/Multi-Shot/Swipe coefficients and isAoe flags from
-- WoWWiki Spell_power_coefficient archive (oldid=1549180, July 2008, patch
-- 2.4.3 era). Stored values are POST-PENALTY empirical coefficients - the
-- engine consumes them verbatim and does not apply additional AoE multipliers.
-------------------------------------------------------------------------------

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns

-------------------------------------------------------------------------------
-- Expected coefficients per spellID. Each entry pins the post-penalty
-- empirical value sourced from the archive. Entries flagged isAoe document
-- whether the spell is a multi-target ability for engine-level routing.
-------------------------------------------------------------------------------
local DIRECT_COEFFICIENT_EXPECTATIONS = {
    -- Mage
    { spellID = 11113, name = "Blast Wave",       coefficient = 0.1357, isAoe = true },
    { spellID = 31661, name = "Dragon's Breath",  coefficient = 0.1357, isAoe = true },
    { spellID = 120,   name = "Cone of Cold",     coefficient = 0.1357, isAoe = true },
    { spellID = 122,   name = "Frost Nova",       coefficient = 0.1357, isAoe = true },
    { spellID = 1449,  name = "Arcane Explosion", coefficient = 0.213,  isAoe = true },
    -- Shaman
    { spellID = 421,   name = "Chain Lightning",  coefficient = 0.7143, isAoe = true },
    -- Priest
    { spellID = 15237, name = "Holy Nova",        coefficient = 0.161,  isAoe = true },
    -- Warlock
    { spellID = 27243, name = "Seed of Corruption", coefficient = 0.2286, isAoe = true },
    { spellID = 30283, name = "Shadowfury",       coefficient = 0.193,  isAoe = true },
}

local CHANNEL_COEFFICIENT_EXPECTATIONS = {
    -- Mage
    { spellID = 10,    name = "Blizzard",         coefficient = 0.7619, isAoe = true },
    -- Druid
    { spellID = 16914, name = "Hurricane",        coefficient = 1.28,   isAoe = true },
    -- Warlock
    { spellID = 5740,  name = "Rain of Fire",     coefficient = 0.952,  isAoe = true },
    { spellID = 1949,  name = "Hellfire",         coefficient = 2.1429, isAoe = true },
    -- Hunter (RAP-scaling channeled AoE)
    { spellID = 1510,  name = "Volley",           coefficient = 0.0586, isAoe = true },
}

local DOT_COEFFICIENT_EXPECTATIONS = {
    -- Paladin
    -- Consecration retains its canonical TBC 2.4.3 value of 0.119 (TOTAL).
    -- The WoWWiki archive's 95.24% figure is stale pre-Patch 2.3 data;
    -- Wowhead spell=20924 SP mod = 0.119 is authoritative.
    { spellID = 26573, name = "Consecration",     coefficient = 0.119,  isAoe = true },
}

local HYBRID_COEFFICIENT_EXPECTATIONS = {
    -- Mage Flamestrike: direct + 8s/4-tick DoT
    {
        spellID            = 2120,
        name               = "Flamestrike",
        directCoefficient  = 0.1761,
        dotCoefficient     = 0.1096,
        isAoe              = true,
    },
}

local AP_COEFFICIENT_EXPECTATIONS = {
    -- Hunter
    { spellID = 2643, name = "Multi-Shot", apCoefficient = 0.20, isAoe = true },
    -- Druid (Bear Swipe)
    { spellID = 779,  name = "Swipe",      apCoefficient = 0.07, isAoe = true },
}

-------------------------------------------------------------------------------
-- Tests
-------------------------------------------------------------------------------
describe("AoE coefficient corrections (issue #46)", function()
    describe("direct-damage AoE spells", function()
        for _, expected in ipairs(DIRECT_COEFFICIENT_EXPECTATIONS) do
            it(string.format("%s (%d) pins coefficient %.4f and isAoe",
                expected.name, expected.spellID, expected.coefficient), function()
                local spell = ns.SpellData[expected.spellID]
                assert.is_not_nil(spell, expected.name .. " missing from SpellData")
                assert.are.equal(expected.name, spell.name)
                assert.is_near(expected.coefficient, spell.coefficient, 0.0001)
                assert.is_true(spell.isAoe == true,
                    expected.name .. " must have isAoe = true")
            end)
        end
    end)

    describe("channeled AoE spells", function()
        for _, expected in ipairs(CHANNEL_COEFFICIENT_EXPECTATIONS) do
            it(string.format("%s (%d) pins coefficient %.4f and isAoe",
                expected.name, expected.spellID, expected.coefficient), function()
                local spell = ns.SpellData[expected.spellID]
                assert.is_not_nil(spell, expected.name .. " missing from SpellData")
                assert.are.equal(expected.name, spell.name)
                assert.is_near(expected.coefficient, spell.coefficient, 0.0001)
                assert.is_true(spell.isAoe == true,
                    expected.name .. " must have isAoe = true")
            end)
        end
    end)

    describe("DoT AoE spells", function()
        for _, expected in ipairs(DOT_COEFFICIENT_EXPECTATIONS) do
            it(string.format("%s (%d) pins coefficient %.4f and isAoe",
                expected.name, expected.spellID, expected.coefficient), function()
                local spell = ns.SpellData[expected.spellID]
                assert.is_not_nil(spell, expected.name .. " missing from SpellData")
                assert.are.equal(expected.name, spell.name)
                assert.is_near(expected.coefficient, spell.coefficient, 0.0001)
                assert.is_true(spell.isAoe == true,
                    expected.name .. " must have isAoe = true")
            end)
        end
    end)

    describe("hybrid (direct + DoT) AoE spells", function()
        for _, expected in ipairs(HYBRID_COEFFICIENT_EXPECTATIONS) do
            it(string.format("%s (%d) pins direct + DoT coefficients and isAoe",
                expected.name, expected.spellID), function()
                local spell = ns.SpellData[expected.spellID]
                assert.is_not_nil(spell, expected.name .. " missing from SpellData")
                assert.are.equal(expected.name, spell.name)
                assert.are.equal("hybrid", spell.spellType)
                assert.is_near(expected.directCoefficient, spell.directCoefficient, 0.0001)
                assert.is_near(expected.dotCoefficient, spell.dotCoefficient, 0.0001)
                assert.is_true(spell.isAoe == true,
                    expected.name .. " must have isAoe = true")
            end)
        end
    end)

    describe("attack-power-scaling AoE spells", function()
        for _, expected in ipairs(AP_COEFFICIENT_EXPECTATIONS) do
            it(string.format("%s (%d) pins AP coefficient %.4f and isAoe",
                expected.name, expected.spellID, expected.apCoefficient), function()
                local spell = ns.SpellData[expected.spellID]
                assert.is_not_nil(spell, expected.name .. " missing from SpellData")
                assert.are.equal(expected.name, spell.name)
                local actual = spell.apCoefficient or spell.coefficient
                assert.is_near(expected.apCoefficient, actual, 0.0001)
                assert.is_true(spell.isAoe == true,
                    expected.name .. " must have isAoe = true")
            end)
        end
    end)
end)
