-------------------------------------------------------------------------------
-- CritCalc.lua
-- Critical strike and hit chance expected value computation
-- Pure Lua — no WoW API calls
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local _, ns = ...

local CritCalc = {}
ns.Engine.CritCalc = CritCalc

local SCHOOL_PHYSICAL = ns.SCHOOL_PHYSICAL

-------------------------------------------------------------------------------
-- ComputeArmorReduction(playerState)
-- Calculates damage reduction from target armor.
-- TBC formula: DR = Armor / (Armor + K), K = 467.5 * Level - 22167.5
-- Returns a fraction [0, 0.75].
-------------------------------------------------------------------------------
function CritCalc.ComputeArmorReduction(playerState)
    local armor = playerState.targetArmor or 0
    if armor <= 0 then return 0 end

    local level = playerState.level or 70
    local K = 467.5 * level - 22167.5
    if K <= 0 then K = 1 end

    local reduction = armor / (armor + K)
    if reduction > 0.75 then reduction = 0.75 end
    if reduction < 0 then reduction = 0 end

    return reduction
end

-------------------------------------------------------------------------------
-- ApplyExpectedCrit(modifiedResult, spellData, playerState, modifiers)
-- Computes expected damage factoring in crit chance, hit chance, and timing.
-- Returns a final SpellResult table.
-------------------------------------------------------------------------------
function CritCalc.ApplyExpectedCrit(modifiedResult, spellData, playerState, modifiers)
    local GCD = ns.GLOBAL_COOLDOWN
    local isRanged = spellData.scalingType == "ranged"

    local hastePercent
    if isRanged then
        hastePercent = playerState.stats.rangedHaste or 0
    else
        hastePercent = playerState.stats.spellHaste or 0
    end
    local hastedGCD = GCD / (1 + hastePercent)
    if hastedGCD < 1.0 then hastedGCD = 1.0 end

    ---------------------------------------------------------------------------
    -- Utility spells — no crit/hit, just pass through
    ---------------------------------------------------------------------------
    if spellData.spellType == "utility" then
        return {
            spellID = modifiedResult.rankData and modifiedResult.rankData.spellID,
            spellName = spellData.name,
            school = spellData.school,
            spellType = spellData.spellType,
            coefficient = modifiedResult.coefficient,
            spellPowerBonus = modifiedResult.spellPowerBonus,
            healthCost = modifiedResult.healthCost,
            manaGain = modifiedResult.manaGain,
            castTime = math.max(modifiedResult.castTime or 0, hastedGCD),
            dps = 0,
            isDot = false,
            isChanneled = false,
        }
    end

    ---------------------------------------------------------------------------
    -- Crit chance
    ---------------------------------------------------------------------------
    local baseCrit
    if isRanged then
        baseCrit = playerState.stats.rangedCrit or 0
    else
        baseCrit = playerState.stats.spellCrit[spellData.school] or 0
    end
    local critChance = baseCrit + modifiers.critBonus
    if spellData.canCrit == false then
        critChance = 0
    end
    if critChance < 0 then
        critChance = 0
    elseif critChance > 1 then
        critChance = 1
    end

    ---------------------------------------------------------------------------
    -- Crit multiplier
    ---------------------------------------------------------------------------
    local critMultiplier = ns.BASE_CRIT_MULTIPLIER + modifiers.critMultBonus

    ---------------------------------------------------------------------------
    -- Hit chance
    ---------------------------------------------------------------------------
    local hitBonus, hitProbability
    if isRanged then
        hitBonus = (playerState.stats.rangedHit or 0) + modifiers.spellHitBonus
        hitProbability = math.min(ns.MAX_RANGED_HIT, 1 - ns.BASE_RANGED_MISS_RATE + hitBonus)
    else
        hitBonus = (playerState.stats.spellHit or 0) + modifiers.spellHitBonus
        hitProbability = math.min(ns.MAX_SPELL_HIT, 1 - ns.BASE_SPELL_MISS_RATE + hitBonus)
    end
    if hitProbability < 0 then
        hitProbability = 0
    end
    if spellData.noMiss then hitProbability = 1.0 end

    ---------------------------------------------------------------------------
    -- Effective cast time
    ---------------------------------------------------------------------------
    local rawCastTime = modifiedResult.castTime or 0
    local hastedCast = rawCastTime
    if rawCastTime > 0 then
        hastedCast = rawCastTime / (1 + hastePercent)
    end
    local effectiveCastTime = math.max(hastedCast, hastedGCD)

    ---------------------------------------------------------------------------
    -- Build final result based on spell type
    ---------------------------------------------------------------------------
    if spellData.spellType == "hybrid" then
        return CritCalc.BuildHybridResult(
            modifiedResult, spellData, critChance, critMultiplier,
            hitBonus, hitProbability, effectiveCastTime, playerState
        )
    end

    if spellData.spellType == "direct" then
        return CritCalc.BuildDirectResult(
            modifiedResult, spellData, critChance, critMultiplier,
            hitBonus, hitProbability, effectiveCastTime, playerState
        )
    end

    -- DoT / Channel
    return CritCalc.BuildPeriodicResult(
        modifiedResult, spellData, critChance, critMultiplier,
        hitBonus, hitProbability, effectiveCastTime,
        hastePercent, playerState
    )
end

-------------------------------------------------------------------------------
-- BuildDirectResult — final result for direct damage spells
-------------------------------------------------------------------------------
function CritCalc.BuildDirectResult(
    modResult, spellData, critChance, critMultiplier,
    hitBonus, hitProbability, effectiveCastTime, playerState)
    local totalDmg = modResult.totalDamage
    local expectedDamage = totalDmg * (1 + critChance * (critMultiplier - 1))
    local expectedWithMiss = expectedDamage * hitProbability

    -- Armor reduction for physical damage
    local armorReduction = 0
    if spellData.school == SCHOOL_PHYSICAL and playerState then
        armorReduction = CritCalc.ComputeArmorReduction(playerState)
        expectedWithMiss = expectedWithMiss * (1 - armorReduction)
    end

    local dps = expectedWithMiss / effectiveCastTime

    return {
        spellID = modResult.rankData and modResult.rankData.spellID,
        spellName = spellData.name,
        school = spellData.school,
        spellType = spellData.spellType,
        baseDamage = { min = modResult.minBaseDamage, max = modResult.maxBaseDamage },
        avgBaseDamage = modResult.avgBaseDamage,
        coefficient = modResult.coefficient,
        spellPowerBonus = modResult.spellPowerBonus,
        damageBeforeMods = modResult.damageBeforeMods,
        damageAfterMods = modResult.totalDamage,
        talentDamageBonus = modResult.talentDamageBonus,
        minDmg = modResult.totalMin,
        maxDmg = modResult.totalMax,
        critChance = critChance,
        critMultiplier = critMultiplier,
        critMult = critMultiplier,
        expectedDamage = expectedDamage,
        hitChance = hitBonus,
        hitProbability = hitProbability,
        expectedDamageWithMiss = expectedWithMiss,
        armorReduction = armorReduction,
        castTime = effectiveCastTime,
        dps = dps,
        isDot = false,
        isChanneled = false,
    }
end

-------------------------------------------------------------------------------
-- BuildPeriodicResult — final result for DoT and channel spells
-------------------------------------------------------------------------------
function CritCalc.BuildPeriodicResult(
    modResult, spellData, critChance, critMultiplier,
    hitBonus, hitProbability, effectiveCastTime,
    hastePercent, playerState)
    local totalDmg = modResult.totalDamage
    local tickDmg = modResult.tickDamage

    local expectedDamage = totalDmg * (1 + critChance * (critMultiplier - 1))
    local expectedWithMiss = expectedDamage * hitProbability
    local expectedTick = (tickDmg * (1 + critChance * (critMultiplier - 1))) * hitProbability

    -- Armor reduction for physical periodic damage
    local armorReduction = 0
    if spellData.school == SCHOOL_PHYSICAL and playerState then
        armorReduction = CritCalc.ComputeArmorReduction(playerState)
        expectedWithMiss = expectedWithMiss * (1 - armorReduction)
        expectedTick = expectedTick * (1 - armorReduction)
    end

    hastePercent = hastePercent or 0
    local effectiveDuration = modResult.duration
    if spellData.isChanneled and hastePercent > 0 and effectiveDuration then
        effectiveDuration = effectiveDuration / (1 + hastePercent)
    end

    local dpsDivisor
    if spellData.isChanneled then
        dpsDivisor = effectiveDuration or effectiveCastTime
    else
        dpsDivisor = effectiveCastTime + (effectiveDuration or 0)
    end
    if dpsDivisor <= 0 then
        dpsDivisor = effectiveCastTime
    end
    local dps = expectedWithMiss / dpsDivisor

    return {
        spellID = modResult.rankData and modResult.rankData.spellID,
        spellName = spellData.name,
        school = spellData.school,
        spellType = spellData.spellType,
        avgBaseDamage = modResult.avgBaseDamage,
        coefficient = modResult.coefficient,
        spellPowerBonus = modResult.spellPowerBonus,
        damageBeforeMods = modResult.damageBeforeMods,
        damageAfterMods = totalDmg,
        talentDamageBonus = modResult.talentDamageBonus,
        totalDmg = totalDmg,
        tickDmg = tickDmg,
        critChance = critChance,
        critMultiplier = critMultiplier,
        critMult = critMultiplier,
        expectedDamage = expectedDamage,
        hitChance = hitBonus,
        hitProbability = hitProbability,
        expectedDamageWithMiss = expectedWithMiss,
        armorReduction = armorReduction,
        castTime = effectiveCastTime,
        dps = dps,
        isDot = spellData.isDot or false,
        isChanneled = spellData.isChanneled or false,
        tickDamage = expectedTick,
        numTicks = modResult.numTicks,
        duration = effectiveDuration,
    }
end

-------------------------------------------------------------------------------
-- BuildHybridResult — final result for hybrid spells (Immolate)
-------------------------------------------------------------------------------
function CritCalc.BuildHybridResult(
    modResult, spellData, critChance, critMultiplier,
    hitBonus, hitProbability, effectiveCastTime, playerState)
    local directDmg = modResult.directDamage
    local expectedDirect = directDmg * (1 + critChance * (critMultiplier - 1))

    local dotDmg = modResult.dotDamage

    local expectedTotal = expectedDirect + dotDmg
    local expectedWithMiss = expectedTotal * hitProbability

    -- Armor reduction for physical hybrid damage
    local armorReduction = 0
    if spellData.school == SCHOOL_PHYSICAL and playerState then
        armorReduction = CritCalc.ComputeArmorReduction(playerState)
        expectedWithMiss = expectedWithMiss * (1 - armorReduction)
    end

    local directWithHit = expectedDirect * hitProbability * (1 - armorReduction)
    local dotWithHit = dotDmg * hitProbability * (1 - armorReduction)

    local totalDuration = effectiveCastTime + (modResult.duration or 0)
    local dps = 0
    if totalDuration > 0 then
        dps = expectedWithMiss / totalDuration
    end

    return {
        spellID = modResult.rankData and modResult.rankData.spellID,
        spellName = spellData.name,
        school = spellData.school,
        spellType = spellData.spellType,
        avgBaseDamage = modResult.avgBaseDamage,
        coefficient = modResult.coefficient,
        spellPowerBonus = modResult.spellPowerBonus,
        damageBeforeMods = modResult.damageBeforeMods,
        damageAfterMods = directDmg + dotDmg,
        talentDamageBonus = modResult.talentDamageBonus,
        directMin = modResult.directMin,
        directMax = modResult.directMax,
        dotTotalDmg = modResult.dotDamage,
        critChance = critChance,
        critMultiplier = critMultiplier,
        critMult = critMultiplier,
        expectedDamage = expectedTotal,
        hitChance = hitBonus,
        hitProbability = hitProbability,
        expectedDamageWithMiss = expectedWithMiss,
        armorReduction = armorReduction,
        castTime = effectiveCastTime,
        dps = dps,
        isDot = true,
        isChanneled = false,
        directDamage = directWithHit,
        directSpBonus = modResult.directSpBonus,
        dotDamage = dotWithHit,
        dotSpBonus = modResult.dotSpBonus,
        tickDamage = dotWithHit / (modResult.numTicks or 1),
        numTicks = modResult.numTicks,
        duration = modResult.duration,
    }
end
