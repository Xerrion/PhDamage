-------------------------------------------------------------------------------
-- test_aoe_coefficients.lua
-- Pins coefficients and isAoe flags for AoE/channel spells per Wowhead TBC
-- Classic data (https://www.wowhead.com/tbc/). Stored values are TOTAL
-- coefficients consumed verbatim by the engine; periodic values are
-- SP_mod x numTicks.
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
    -- Shaman (Wowhead spell=25442 SP mod = 0.651)
    { spellID = 421,   name = "Chain Lightning",  coefficient = 0.651,  isAoe = true },
    -- Priest
    { spellID = 15237, name = "Holy Nova",        coefficient = 0.161,  isAoe = true },
    -- Warlock (Wowhead spell=27243 detonation SP mod = 0.214)
    { spellID = 27243, name = "Seed of Corruption", coefficient = 0.214,  isAoe = true },
    { spellID = 30283, name = "Shadowfury",       coefficient = 0.193,  isAoe = true },
}

local CHANNEL_COEFFICIENT_EXPECTATIONS = {
    -- Mage (Wowhead spell=27085 per-tick SP mod 0.119 x 8 ticks = 0.952)
    { spellID = 10,    name = "Blizzard",         coefficient = 0.952,  isAoe = true },
    -- Druid (Wowhead spell=27012 per-tick SP mod 0.107 x 10 ticks = 1.07)
    { spellID = 16914, name = "Hurricane",        coefficient = 1.07,   isAoe = true },
    -- Warlock
    { spellID = 5740,  name = "Rain of Fire",     coefficient = 0.952,  isAoe = true },
    -- Warlock (Wowhead spell=27213 per-tick SP mod 0.095 x 15 ticks = 1.425)
    { spellID = 1949,  name = "Hellfire",         coefficient = 1.425,  isAoe = true },
    -- Hunter (RAP-scaling channeled AoE)
    { spellID = 1510,  name = "Volley",           coefficient = 0.0586, isAoe = true },
}

local DOT_COEFFICIENT_EXPECTATIONS = {
    -- Paladin
    -- Consecration: per-tick SP mod 0.119 x 8 ticks = 0.952 (TOTAL).
    -- Engine treats `coefficient` as TOTAL across the duration.
    -- Source: https://www.wowhead.com/tbc/spell=27173
    { spellID = 26573, name = "Consecration",     coefficient = 0.952,  isAoe = true },
}

local HYBRID_COEFFICIENT_EXPECTATIONS = {
    -- Mage Flamestrike: direct + 8s/4-tick DoT
    -- Wowhead direct SP mod 0.236; DoT per-tick SP mod 0.03 x 4 = 0.12 total.
    -- Source: https://www.wowhead.com/tbc/spell=27086
    {
        spellID            = 2120,
        name               = "Flamestrike",
        directCoefficient  = 0.236,
        dotCoefficient     = 0.12,
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
