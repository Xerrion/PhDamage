-------------------------------------------------------------------------------
-- LevelPenalty.lua
-- TBC downranking spell-coefficient level penalty (cMaNGOS-TBC formula).
-- Pure Lua - no WoW API calls.
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local _, ns = ...

ns.Engine = ns.Engine or {}

local LevelPenalty = {}
ns.Engine.LevelPenalty = LevelPenalty

-------------------------------------------------------------------------------
-- CalculateLevelPenalty(spellLevel, maxLevel, playerLevel)
--
-- Returns the SP-coefficient multiplier in [0.0, 1.0] applied to spell power
-- contribution when a sub-max-rank spell is cast at higher levels (downranking
-- penalty introduced in patch 2.2).
--
-- cMaNGOS-TBC reference (Unit.cpp::CalculateLevelPenalty):
--   https://github.com/cmangos/mangos-tbc/blob/master/src/game/Entities/Unit.cpp
--
-- Formula (verbatim port):
--   if spellLevel <= 0 or spellLevel >= maxSpellLevel then return 1.0
--   LvlPenalty = (spellLevel < 20) and (20 - spellLevel) * 3.75 or 0
--   LvlFactor  = (maxSpellLevel + 6) / playerLevel, capped at 1.0
--   return (100 - LvlPenalty) * LvlFactor / 100
--
-- TBC vs WotLK divergence: TBC uses `MaxLevel + 6`; AzerothCore and cMaNGOS-WotLK
-- use `SpellLevel + 6`. We are TBC-targeted, so MaxLevel + 6 is correct - see
-- issue #47 body and the Schlemiel-10753 EU forum citation (2026-01-14) which
-- confirms the 2.2 patch formula.
--
-- Defensive nil/zero policy: any missing or non-positive input returns 1.0
-- (no penalty). This is critical during incremental data backfill - per-rank
-- entries without `maxLevel` populated yet must not regress existing behavior.
-- Phase 1-3 must remain green even before Phase 4 backfills the data.
-------------------------------------------------------------------------------
function LevelPenalty.CalculateLevelPenalty(spellLevel, maxLevel, playerLevel)
    if spellLevel == nil or maxLevel == nil then return 1.0 end
    if playerLevel == nil or playerLevel <= 0 then return 1.0 end
    if spellLevel <= 0 then return 1.0 end
    if spellLevel >= maxLevel then return 1.0 end

    local lvlPenalty = 0.0
    if spellLevel < 20 then
        lvlPenalty = (20.0 - spellLevel) * 3.75
    end

    local lvlFactor = (maxLevel + 6.0) / playerLevel
    if lvlFactor > 1.0 then lvlFactor = 1.0 end

    return (100.0 - lvlPenalty) * lvlFactor / 100.0
end

