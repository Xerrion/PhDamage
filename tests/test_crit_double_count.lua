-------------------------------------------------------------------------------
-- test_crit_double_count.lua
-- Regression: ensures that talents whose crit bonuses are already reported by
-- the WoW API (and collected into stats.spellCrit / stats.meleeCrit /
-- stats.rangedCrit) are NOT also present in TalentMap. Plan 44, Bug A.
-- Supported versions: TBC Classic, MoP Classic, Retail
-------------------------------------------------------------------------------

require("busted.runner")()

local bootstrap = require("tests.bootstrap")
local ns = bootstrap.ns

describe("Plan 44 Bug A: removed double-counted crit talents", function()

    -- Each entry maps a TalentMap key (CLASS:tab:index) to a human-readable name
    -- for diagnostic output when the assertion fails.
    local removed = {
        ["DRUID:2:5"]   = "Sharpened Claws",
        ["DRUID:3:18"]  = "Natural Perfection",
        ["HUNTER:2:4"]  = "Lethal Shots",
        ["HUNTER:3:18"] = "Survival Instincts",
        ["MAGE:2:11"]   = "Critical Mass",
        ["MAGE:2:20"]   = "Pyromaniac",
        ["PALADIN:1:13"] = "Holy Power",
        ["PALADIN:2:20"] = "Combat Expertise",
        ["PALADIN:3:21"] = "Sanctified Seals",
        ["PRIEST:2:2"]  = "Holy Specialization",
        ["ROGUE:1:3"]   = "Malice",
        ["ROGUE:2:2"]   = "Dagger Specialization",
        ["ROGUE:2:3"]   = "Fist Weapon Specialization",
        ["WARLOCK:2:20"] = "Demonic Tactics",
        ["WARLOCK:3:21"] = "Backlash",
        ["WARRIOR:1:11"] = "Poleaxe Specialization",
        ["WARRIOR:2:4"]  = "Cruelty",
    }

    for key, name in pairs(removed) do
        it(string.format("must not define %s (%s) in TalentMap", key, name), function()
            assert.is_nil(
                ns.TalentMap[key],
                string.format(
                    "TalentMap[%q] (%s) is still present; its crit bonus is already counted in stats.*Crit. " ..
                    "Re-adding it would double-count the bonus. See plan 44, Bug A.",
                    key, name
                )
            )
        end)
    end

    it("must keep partial-deletion entries (Mage Arcane Instability, Priest Force of Will)", function()
        -- These talents had their CRIT_BONUS effect removed (already in spellCrit) but
        -- retain their DAMAGE_MULTIPLIER effect. Their entries must still exist.
        assert.is_not_nil(
            ns.TalentMap["MAGE:1:14"],
            "MAGE:1:14 (Arcane Instability) should keep its DAMAGE_MULTIPLIER effect."
        )
        assert.is_not_nil(
            ns.TalentMap["PRIEST:1:15"],
            "PRIEST:1:15 (Force of Will) should keep its DAMAGE_MULTIPLIER effect."
        )
    end)

    it("must not retain any CRIT_BONUS effect on partial-deletion entries", function()
        -- The CRIT_BONUS effect on these talents was the double-counted one. Only the
        -- DAMAGE_MULTIPLIER effect should survive after the partial deletion.
        for _, eff in ipairs(ns.TalentMap["MAGE:1:14"].effects) do
            assert.are_not.equal(ns.MOD.CRIT_BONUS, eff.type,
                "MAGE:1:14 (Arcane Instability) still has a CRIT_BONUS effect; it must be removed.")
        end
        for _, eff in ipairs(ns.TalentMap["PRIEST:1:15"].effects) do
            assert.are_not.equal(ns.MOD.CRIT_BONUS, eff.type,
                "PRIEST:1:15 (Force of Will) still has a CRIT_BONUS effect; it must be removed.")
        end
    end)
end)
