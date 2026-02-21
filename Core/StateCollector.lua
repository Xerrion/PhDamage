-------------------------------------------------------------------------------
-- StateCollector.lua
-- Reads WoW APIs to produce a PlayerState snapshot for the engine
-- This is the bridge between WoW and the pure-Lua engine
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-- Cache WoW API functions as locals
local UnitLevel = UnitLevel
local UnitClass = UnitClass
local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellBonusHealing = GetSpellBonusHealing
local GetSpellCritChance = GetSpellCritChance
local GetCombatRatingBonus = GetCombatRatingBonus
local GetTalentInfo = GetTalentInfo
local GetNumTalentTabs = GetNumTalentTabs
local GetNumTalents = GetNumTalents
local GetManaRegen = GetManaRegen

local StateCollector = {}
ns.StateCollector = StateCollector

-- School index to bitmask constant mapping
-- GetSpellBonusDamage(school) uses: 1=Physical, 2=Holy, 3=Fire, 4=Nature, 5=Frost, 6=Shadow, 7=Arcane
local schoolIndexToConstant = {
    [1] = ns.SCHOOL_PHYSICAL,
    [2] = ns.SCHOOL_HOLY,
    [3] = ns.SCHOOL_FIRE,
    [4] = ns.SCHOOL_NATURE,
    [5] = ns.SCHOOL_FROST,
    [6] = ns.SCHOOL_SHADOW,
    [7] = ns.SCHOOL_ARCANE,
}

function StateCollector.CollectPlayerState()
    local state = {
        level = UnitLevel("player"),
        class = select(2, UnitClass("player")),  -- English class token
        stats = {
            spellPower = {},
            healingPower = 0,
            spellCrit = {},
            spellHit = 0,
            spellHaste = 0,
        },
        talents = {},
        auras = {
            player = {},
            target = {},
        },
        gear = {
            setBonuses = {},
        },
    }

    local ok, result

    -- Collect spell power per school (skip physical at index 1)
    for i = 2, 7 do
        ok, result = pcall(GetSpellBonusDamage, i)
        if ok and result then
            state.stats.spellPower[schoolIndexToConstant[i]] = result
        end
    end

    -- Healing power
    ok, result = pcall(GetSpellBonusHealing)
    if ok and result then
        state.stats.healingPower = result
    end

    -- Spell crit per school (same school indices as spell power)
    for i = 2, 7 do
        ok, result = pcall(GetSpellCritChance, i)
        if ok and result then
            state.stats.spellCrit[schoolIndexToConstant[i]] = result / 100  -- Convert percentage to fraction
        end
    end

    -- Spell hit from rating (CR_HIT_SPELL)
    ok, result = pcall(GetCombatRatingBonus, ns.CR_HIT_SPELL)
    if ok and result then
        state.stats.spellHit = result / 100
    end

    -- Spell haste from rating (CR_HASTE_SPELL)
    ok, result = pcall(GetCombatRatingBonus, ns.CR_HASTE_SPELL)
    if ok and result then
        state.stats.spellHaste = result / 100
    end

    -- Mana regen
    do
        local ok, base, casting = pcall(GetManaRegen)
        if ok then
            state.stats.manaRegen = { base = base or 0, casting = casting or 0 }
        end
    end

    -- Talents
    StateCollector.CollectTalents(state)

    -- Auras
    StateCollector.CollectAuras(state)

    return state
end

function StateCollector.CollectTalents(state)
    local numTabs = GetNumTalentTabs and GetNumTalentTabs() or 0
    for tab = 1, numTabs do
        local numTalents = GetNumTalents and GetNumTalents(tab) or 0
        for index = 1, numTalents do
            local ok, name, _, _, _, rank = pcall(GetTalentInfo, tab, index)
            if ok and name and rank and rank > 0 then
                local key = tab .. ":" .. index
                state.talents[key] = rank
            end
        end
    end
end

function StateCollector.CollectAuras(state)
    -- Build a set of aura spellIDs we care about for quick lookup
    local watchedAuras = {}
    if ns.AuraMap then
        for spellID, entry in pairs(ns.AuraMap) do
            watchedAuras[spellID] = entry.target
        end
    end

    -- Scan player buffs using C_UnitAuras.GetPlayerAuraBySpellID if available
    local hasGetPlayerAura = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID
    if hasGetPlayerAura then
        for spellID, target in pairs(watchedAuras) do
            if target == "player" then
                local auraData = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                if auraData then
                    state.auras.player[spellID] = true
                end
            end
        end
    end

    -- Helper to scan auras on a unit via C_UnitAuras
    local scanUnit = function(unit, auraType, stateKey)
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            local i = 1
            while true do
                local ok, auraData = pcall(C_UnitAuras.GetAuraDataByIndex, unit, i, auraType)
                if not ok or not auraData then break end
                if auraData.spellId and watchedAuras[auraData.spellId] then
                    state.auras[stateKey][auraData.spellId] = true
                end
                i = i + 1
            end
        end
    end

    -- Scan target debuffs via C_UnitAuras
    scanUnit("target", "HARMFUL", "target")

    -- Scan player buffs via C_UnitAuras if GetPlayerAuraBySpellID was not available
    if not hasGetPlayerAura then
        scanUnit("player", "HELPFUL", "player")
    end
end

-------------------------------------------------------------------------------
-- Cached state management
-------------------------------------------------------------------------------

local cachedState = nil
local isDirty = true

function StateCollector.Invalidate()
    isDirty = true
end

function StateCollector.GetCachedState()
    if isDirty or not cachedState then
        cachedState = StateCollector.CollectPlayerState()
        isDirty = false
    end
    return cachedState
end

-- StateCollector is accessible via ns.StateCollector
