-------------------------------------------------------------------------------
-- StateCollector.lua
-- Reads WoW APIs to produce a PlayerState snapshot for the engine
-- This is the bridge between WoW and the pure-Lua engine
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local _, ns = ...

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
local UnitRangedAttackPower = UnitRangedAttackPower
local GetRangedCritChance = GetRangedCritChance
local UnitCreatureType = UnitCreatureType
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitCanAttack = UnitCanAttack
local UnitRangedDamage = UnitRangedDamage
local UnitAttackPower = UnitAttackPower
local GetCritChance = GetCritChance
local GetExpertise = GetExpertise
local UnitDamage = UnitDamage
local UnitAttackSpeed = UnitAttackSpeed
local GetInventoryItemLink = GetInventoryItemLink
local GetItemInfo = GetItemInfo

local StateCollector = {}
ns.StateCollector = StateCollector

-------------------------------------------------------------------------------
-- Armor Debuff SpellIDs and their per-application reduction values
-------------------------------------------------------------------------------
local ARMOR_DEBUFFS = {
    [7386]  = { reduction = 520,  stacks = true,  maxStacks = 5 },   -- Sunder Armor
    [770]   = { reduction = 610,  stacks = false },                   -- Faerie Fire
    [704]   = { reduction = 800,  stacks = false },                   -- Curse of Recklessness
    [26866] = { reduction = 2050, stacks = false },                   -- Expose Armor (Rank 5)
    [11198] = { reduction = 2550, stacks = false },                   -- Expose Armor (Rank 4)
}

-- Base armor by mob level (TBC estimates for normal mobs)
local BASE_MOB_ARMOR = {
    [70] = 7684,
    [71] = 7684,
    [72] = 7684,
    [73] = 7684,  -- Boss
}
local DEFAULT_MOB_ARMOR = 7684

-------------------------------------------------------------------------------
-- EstimateTargetArmor(state)
-- Estimates target armor based on level and tracked armor debuffs.
-------------------------------------------------------------------------------
local function EstimateTargetArmor(state)
    if not UnitExists("target") or not UnitCanAttack("player", "target") then
        return 0
    end

    local targetLevel = UnitLevel("target") or -1
    if targetLevel == -1 then
        targetLevel = state.level + 3  -- Boss: assume player level + 3
    end

    local baseArmor = BASE_MOB_ARMOR[targetLevel] or DEFAULT_MOB_ARMOR

    if not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex then return baseArmor end

    -- Scan for armor reduction debuffs on target
    local totalReduction = 0
    for i = 1, 40 do
        local ok, auraData = pcall(C_UnitAuras.GetAuraDataByIndex, "target", i, "HARMFUL")
        if not ok or not auraData then break end

        local debuffInfo = ARMOR_DEBUFFS[auraData.spellId]
        if debuffInfo then
            if debuffInfo.stacks then
                local stacks = auraData.applications or 1
                if stacks > debuffInfo.maxStacks then
                    stacks = debuffInfo.maxStacks
                end
                totalReduction = totalReduction + (debuffInfo.reduction * stacks)
            else
                totalReduction = totalReduction + debuffInfo.reduction
            end
        end
    end

    local effectiveArmor = baseArmor - totalReduction
    if effectiveArmor < 0 then effectiveArmor = 0 end

    return effectiveArmor
end

-- Affliction spell IDs for Soul Siphon counting
-- Includes: Curses, Corruption, SoC, Siphon Life, UA, Drain Life, Fear, Immolate
local AFFLICTION_SPELL_IDS = {
    -- Corruption (all ranks - base spellID 172)
    [172] = true, [6222] = true, [6223] = true, [7648] = true,
    [11671] = true, [11672] = true, [25311] = true, [27216] = true,
    -- Curse of Agony (all ranks - base 980)
    [980] = true, [1014] = true, [6217] = true, [11711] = true,
    [11712] = true, [11713] = true, [27218] = true,
    -- Unstable Affliction (all ranks - base 30108)
    [30108] = true, [30404] = true, [30405] = true,
    -- Siphon Life (all ranks - base 18265)
    [18265] = true, [18879] = true, [18880] = true, [18881] = true,
    [27264] = true, [30911] = true,
    -- Curse of Doom (all ranks)
    [603] = true, [30910] = true,
    -- Curse of Elements (all ranks)
    [1490] = true, [11721] = true, [11722] = true, [27228] = true,
    -- Curse of Shadow (all ranks)
    [17862] = true, [17937] = true, [32862] = true,
    -- Curse of Recklessness (all ranks)
    [704] = true, [7658] = true, [7659] = true, [11717] = true, [27226] = true,
    -- Curse of Tongues (all ranks)
    [1714] = true, [11719] = true,
    -- Curse of Weakness (all ranks)
    [702] = true, [1108] = true, [6205] = true, [7646] = true,
    [11707] = true, [11708] = true, [27224] = true, [30909] = true,
    -- Seed of Corruption
    [27243] = true,
    -- Drain Life (all ranks - self counts as affliction effect)
    [689] = true, [699] = true, [709] = true, [7651] = true,
    [11699] = true, [11700] = true, [27219] = true, [27220] = true,
    -- Fear
    [5782] = true, [6213] = true, [6215] = true,
    -- Immolate (all ranks - counts as affliction dot on target)
    [348] = true, [707] = true, [1094] = true, [2941] = true,
    [11665] = true, [11667] = true, [11668] = true, [25309] = true, [27215] = true,
}

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

            -- Ranged stats (for Hunter)
            rangedAttackPower = 0,
            rangedCrit = 0,
            rangedHit = 0,
            rangedHaste = 0,
            weaponDamage = nil,
            rangedSpeed = 0,
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
        if ok and result ~= nil then
            state.stats.spellPower[schoolIndexToConstant[i]] = result
        end
    end

    -- Healing power
    ok, result = pcall(GetSpellBonusHealing)
    if ok and result ~= nil then
        state.stats.healingPower = result
    end

    -- Spell crit per school (same school indices as spell power)
    for i = 2, 7 do
        ok, result = pcall(GetSpellCritChance, i)
        if ok and result ~= nil then
            state.stats.spellCrit[schoolIndexToConstant[i]] = result / 100  -- Convert percentage to fraction
        end
    end

    -- Spell hit from rating (CR_HIT_SPELL)
    ok, result = pcall(GetCombatRatingBonus, ns.CR_HIT_SPELL)
    if ok and result ~= nil then
        state.stats.spellHit = result / 100
    end

    -- Spell haste from rating (CR_HASTE_SPELL)
    ok, result = pcall(GetCombatRatingBonus, ns.CR_HASTE_SPELL)
    if ok and result ~= nil then
        state.stats.spellHaste = result / 100
    end

    -- Mana regen
    do
        local ok, base, casting = pcall(GetManaRegen)
        if ok then
            state.stats.manaRegen = { base = base or 0, casting = casting or 0 }
        end
    end

    -- Intellect (needed for stat-conversion talents like Lunar Guidance)
    do
        local ok, _, intel = pcall(UnitStat, "player", 4)
        if ok and intel then
            state.stats.intellect = intel
        end
    end

    ---------------------------------------------------------------------------
    -- Ranged combat stats (Hunter, etc.)
    ---------------------------------------------------------------------------
    if state.class == "HUNTER" then
        local ok, base, pos, neg = pcall(UnitRangedAttackPower, "player")
        if ok then
            state.stats.rangedAttackPower = base + pos + neg
        end

        local val
        ok, val = pcall(GetRangedCritChance)
        if ok and val then
            state.stats.rangedCrit = val / 100
        end

        ok, val = pcall(GetCombatRatingBonus, ns.CR_HIT_RANGED)
        if ok and val then
            state.stats.rangedHit = val / 100
        end

        ok, val = pcall(GetCombatRatingBonus, ns.CR_HASTE_RANGED)
        if ok and val then
            state.stats.rangedHaste = val / 100
        end

        -- Ranged weapon damage
        local ok2, speed, minDmg, maxDmg = pcall(UnitRangedDamage, "player")
        if ok2 and speed and speed > 0 then
            state.stats.weaponDamage = { min = minDmg or 0, max = maxDmg or 0 }
            state.stats.rangedSpeed = speed
        end
    end

    ---------------------------------------------------------------------------
    -- Melee combat stats
    ---------------------------------------------------------------------------
    if state.class == "WARRIOR" or state.class == "ROGUE" or state.class == "PALADIN"
        or state.class == "DEATHKNIGHT" or state.class == "DRUID" or state.class == "SHAMAN" then
        local base, posBuff, negBuff = UnitAttackPower("player")
        state.stats.attackPower = base + posBuff + negBuff

        state.stats.meleeCrit = GetCritChance() / 100

        local hitRating = GetCombatRatingBonus(ns.CR_HIT_MELEE)
        state.stats.meleeHit = hitRating / 100

        local hasteRating = GetCombatRatingBonus(ns.CR_HASTE_MELEE)
        state.stats.meleeHaste = hasteRating / 100

        state.stats.expertise = GetExpertise()

        -- Main hand weapon damage (subtract AP contribution to get raw weapon damage,
        -- since UnitDamage includes AP and the engine adds normalized AP separately)
        local minDmg, maxDmg, _, _, _, _, _ = UnitDamage("player")
        local mainSpeed, _ = UnitAttackSpeed("player")
        state.stats.mainHandWeaponSpeed = mainSpeed

        local apContribution = (state.stats.attackPower / 14) * mainSpeed
        state.stats.mainHandWeaponDmgMin = minDmg - apContribution
        state.stats.mainHandWeaponDmgMax = maxDmg - apContribution

        -- Determine weapon type for normalization
        local weaponLink = GetInventoryItemLink("player", 16)  -- INVSLOT_MAINHAND
        if weaponLink then
            local _, _, _, _, _, _, itemSubType = GetItemInfo(weaponLink)
            if itemSubType then
                if itemSubType == "Two-Handed Swords" or itemSubType == "Two-Handed Maces"
                    or itemSubType == "Two-Handed Axes" or itemSubType == "Polearms"
                    or itemSubType == "Staves" or itemSubType == "Fishing Poles" then
                    state.stats.mainHandWeaponType = "TWO_HAND"
                elseif itemSubType == "Daggers" then
                    state.stats.mainHandWeaponType = "DAGGER"
                elseif itemSubType == "Fist Weapons" then
                    state.stats.mainHandWeaponType = "FIST"
                else
                    state.stats.mainHandWeaponType = "ONE_HAND"
                end
            end
        end

        state.stats.attackingFromBehind = true  -- Default assumption for PvE
    end

    -- Talents
    StateCollector.CollectTalents(state)

    -- Auras
    StateCollector.CollectAuras(state)

    -- Target armor estimation (for physical damage calculations)
    state.targetArmor = EstimateTargetArmor(state)

    -- Target creature type (for Monster/Humanoid Slaying talents)
    if UnitExists("target") then
        state.targetCreatureType = UnitCreatureType("target")
    end

    -- Target health percentage (for Molten Fury etc.)
    if UnitExists("target") then
        local hp = UnitHealth("target")
        local hpMax = UnitHealthMax("target")
        state.targetHealthPercent = (hpMax > 0) and (hp / hpMax * 100) or 100
    else
        state.targetHealthPercent = 100
    end

    return state
end

function StateCollector.CollectTalents(state)
    -- Build reverse lookup from talent name -> TalentMap key for this class.
    -- This makes talent collection immune to index reordering across client
    -- versions (e.g. TBC Anniversary orders by internal talentID, not grid position).
    local nameToKey = {}
    local classPrefix = (state.class or "UNKNOWN") .. ":"
    for mapKey, entry in pairs(ns.TalentMap) do
        if mapKey:sub(1, #classPrefix) == classPrefix then
            local talentKey = mapKey:sub(#classPrefix + 1)
            nameToKey[entry.name] = talentKey
        end
    end

    local numTabs = GetNumTalentTabs and GetNumTalentTabs() or 0
    for tab = 1, numTabs do
        local numTalents = GetNumTalents and GetNumTalents(tab) or 0
        for index = 1, numTalents do
            local ok, name, _, _, _, rank = pcall(GetTalentInfo, tab, index)
            if ok and name and rank and rank > 0 then
                local mappedKey = nameToKey[name]
                if mappedKey then
                    -- Clamp rank to maxRank as defense-in-depth
                    local entry = ns.TalentMap[classPrefix .. mappedKey]
                    if entry and entry.maxRank and rank > entry.maxRank then
                        rank = entry.maxRank
                    end
                    state.talents[mappedKey] = rank
                else
                    -- Untracked talent: store with raw key for diagnostics visibility
                    local rawKey = tab .. ":" .. index
                    state.talents[rawKey] = rank
                end
            end
        end
    end
end

-- Cached watched-auras set; ns.AuraMap is static after addon init
local watchedAurasCache = nil

local function GetWatchedAuras()
    if watchedAurasCache then return watchedAurasCache end
    watchedAurasCache = {}
    if ns.AuraMap then
        for spellID, entry in pairs(ns.AuraMap) do
            watchedAurasCache[spellID] = entry.target
        end
    end
    return watchedAurasCache
end

function StateCollector.CollectAuras(state)
    local watchedAuras = GetWatchedAuras()

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

    -- Scan target debuffs via C_UnitAuras (also count affliction effects for Soul Siphon)
    local afflictionCount = 0
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        local i = 1
        while true do
            local ok, auraData = pcall(C_UnitAuras.GetAuraDataByIndex, "target", i, "HARMFUL")
            if not ok or not auraData then break end
            if auraData.spellId then
                if watchedAuras[auraData.spellId] then
                    state.auras.target[auraData.spellId] = true
                end
                if AFFLICTION_SPELL_IDS[auraData.spellId] then
                    afflictionCount = afflictionCount + 1
                end
            end
            i = i + 1
        end
    end
    state.afflictionCountOnTarget = afflictionCount

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
