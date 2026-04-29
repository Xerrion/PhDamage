-------------------------------------------------------------------------------
-- SpellResolver.lua
-- Resolves any known spell ID (base, rank cast, or per-tick effect) to the
-- base SpellData key plus rank index. Pure Lua: no WoW API, no events.
--
-- Loaded after Data/ so ns.SpellData is fully populated before first use.
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local _, ns = ...

-- Cache stdlib globals used during the (rare) build pass and (frequent) lookup
local pairs = pairs
local ipairs = ipairs
local type = type

---@class SpellResolver
local SpellResolver = {}
ns.SpellResolver = SpellResolver

-------------------------------------------------------------------------------
-- Internal lookup table
--
-- Shape: { [anySpellID] = { baseID, rankIndex } }
--
-- Built lazily on first Resolve() call. Cached for the rest of the session
-- because ns.SpellData is declarative and never mutated at runtime today.
-- If a future feature mutates ns.SpellData (hot-reload, debug overrides),
-- callers MUST invoke SpellResolver.Rebuild() afterwards.
-------------------------------------------------------------------------------
local lookup = nil

-------------------------------------------------------------------------------
-- Build()
-- Walks ns.SpellData once and populates the lookup table with every known
-- spell ID variant: base ID, per-rank cast IDs, and per-rank effect IDs
-- (used by TBC channel spells where the visible cast and the per-tick proc
-- have distinct spell IDs, e.g. Hellfire R4: 27213 cast / 27214 effect).
--
-- For the base ID itself, we point at rank 1 only when rank 1's spellID
-- happens to equal the base ID (the common Wowhead convention). Otherwise
-- the rank index is left nil so the engine falls back to its level-gated
-- rank selection. This matches the existing Tooltip.lua contract.
-------------------------------------------------------------------------------
local function Build()
    lookup = {}
    for baseID, spellEntry in pairs(ns.SpellData) do
        local ranks = spellEntry.ranks
        local baseRankIndex = nil

        if ranks then
            for rankIndex, rankData in ipairs(ranks) do
                if rankData.spellID then
                    lookup[rankData.spellID] = { baseID, rankIndex }
                    if rankData.spellID == baseID and baseRankIndex == nil then
                        baseRankIndex = rankIndex
                    end
                end
                if rankData.effectID then
                    lookup[rankData.effectID] = { baseID, rankIndex }
                end
            end
        end

        -- Ensure the base ID itself always resolves, even when no rank's
        -- spellID matches it. Preserve any rank-1-equals-base mapping that
        -- was discovered during the rank walk above.
        if lookup[baseID] == nil then
            lookup[baseID] = { baseID, baseRankIndex }
        end
    end
end

---Resolve a spell ID (base, rank cast, or per-tick effect) to its base
---SpellData key plus rank index.
---@param spellID number
---@return number? baseID The key in ns.SpellData, or nil if unknown
---@return number? rankIndex The rank index within ns.SpellData[baseID].ranks, or nil
function SpellResolver.Resolve(spellID)
    if type(spellID) ~= "number" then
        return nil, nil
    end

    if lookup == nil then
        Build()
    end

    local entry = lookup[spellID]
    if not entry then
        return nil, nil
    end

    return entry[1], entry[2]
end

---Force a rebuild of the internal lookup table. Call after ns.SpellData
---mutations (currently never happens; future-proofing for hot-reload).
function SpellResolver.Rebuild()
    lookup = nil
end
