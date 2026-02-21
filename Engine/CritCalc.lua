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

-------------------------------------------------------------------------------
-- ApplyExpectedCrit(modifiedResult, spellData, playerState, modifiers)
-- Computes expected damage factoring in crit chance, hit chance, and timing.
-- Returns a final SpellResult table.
-------------------------------------------------------------------------------
function CritCalc.ApplyExpectedCrit(modifiedResult, spellData, playerState, modifiers)
    local GCD = ns.GLOBAL_COOLDOWN
    local hastePercent = playerState.stats.spellHaste or 0
    local hastedGCD = GCD / (1 + hastePercent)
    if hastedGCD < 1.0 then hastedGCD = 1.0 end

    ---------------------------------------------------------------------------
    -- Utility spells (Life Tap) — no crit/hit, just pass through
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
    local baseCrit = playerState.stats.spellCrit[spellData.school] or 0
    local critChance = baseCrit + modifiers.critBonus
    -- If spell explicitly cannot crit, set crit chance to 0
    if spellData.canCrit == false then
        critChance = 0
    end
    -- Clamp to [0, 1]
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
    local rawHit = 1 - ns.BASE_SPELL_MISS_RATE + playerState.stats.spellHit + modifiers.spellHitBonus
    local hitChance = math.min(ns.MAX_SPELL_HIT, rawHit)
    if hitChance < 0 then
        hitChance = 0
    end
    if spellData.noMiss then hitChance = 1.0 end

    ---------------------------------------------------------------------------
    -- Effective cast time (minimum GCD for instants)
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
            modifiedResult, spellData, critChance, critMultiplier, hitChance, effectiveCastTime
        )
    end

    if spellData.spellType == "direct" then
        return CritCalc.BuildDirectResult(
            modifiedResult, spellData, critChance, critMultiplier, hitChance, effectiveCastTime
        )
    end

    -- DoT / Channel
    return CritCalc.BuildPeriodicResult(
        modifiedResult, spellData, critChance, critMultiplier, hitChance, effectiveCastTime, hastePercent
    )
end

-------------------------------------------------------------------------------
-- BuildDirectResult — final result for direct damage spells
-------------------------------------------------------------------------------
function CritCalc.BuildDirectResult(modResult, spellData, critChance, critMultiplier, hitChance, effectiveCastTime)
    local totalDmg = modResult.totalDamage
    local expectedDamage = totalDmg * (1 + critChance * (critMultiplier - 1))
    local expectedWithMiss = expectedDamage * hitChance
    local dps = expectedWithMiss / effectiveCastTime

    return {
        spellID = modResult.rankData and modResult.rankData.spellID,
        spellName = spellData.name,
        school = spellData.school,
        spellType = spellData.spellType,
        -- Base values
        baseDamage = { min = modResult.minBaseDamage, max = modResult.maxBaseDamage },
        avgBaseDamage = modResult.avgBaseDamage,
        coefficient = modResult.coefficient,
        spellPowerBonus = modResult.spellPowerBonus,
        -- Modifier values
        damageBeforeMods = modResult.damageBeforeMods,
        damageAfterMods = modResult.totalDamage,
        talentDamageBonus = modResult.talentDamageBonus,
        -- Crit values
        critChance = critChance,
        critMultiplier = critMultiplier,
        expectedDamage = expectedDamage,
        -- Hit values
        hitChance = hitChance,
        expectedDamageWithMiss = expectedWithMiss,
        -- Timing
        castTime = effectiveCastTime,
        dps = dps,
        -- Flags
        isDot = false,
        isChanneled = false,
    }
end

-------------------------------------------------------------------------------
-- BuildPeriodicResult — final result for DoT and channel spells
-------------------------------------------------------------------------------
function CritCalc.BuildPeriodicResult(modResult, spellData, critChance, critMultiplier, hitChance, effectiveCastTime, hastePercent)
    local totalDmg = modResult.totalDamage
    local tickDmg = modResult.tickDamage

    -- DoTs/channels generally don't crit in TBC, but we respect spellData.canCrit
    local expectedDamage = totalDmg * (1 + critChance * (critMultiplier - 1))
    local expectedWithMiss = expectedDamage * hitChance
    local expectedTick = (tickDmg * (1 + critChance * (critMultiplier - 1))) * hitChance

    -- DPS: for DoTs/channels, include cast time in denominator for throughput DPS
    -- Channels: duration IS the cast time, so just use duration
    -- DoTs with cast time: use castTime + duration
    hastePercent = hastePercent or 0
    local effectiveDuration = modResult.duration
    if spellData.isChanneled and hastePercent > 0 and effectiveDuration then
        effectiveDuration = effectiveDuration / (1 + hastePercent)
    end

    -- DPS divisor: channels use their (hasted) duration, DoTs use cast + duration
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
        -- Base values
        avgBaseDamage = modResult.avgBaseDamage,
        coefficient = modResult.coefficient,
        spellPowerBonus = modResult.spellPowerBonus,
        -- Modifier values
        damageBeforeMods = modResult.damageBeforeMods,
        damageAfterMods = totalDmg,
        talentDamageBonus = modResult.talentDamageBonus,
        -- Crit values
        critChance = critChance,
        critMultiplier = critMultiplier,
        expectedDamage = expectedDamage,
        -- Hit values
        hitChance = hitChance,
        expectedDamageWithMiss = expectedWithMiss,
        -- Timing
        castTime = effectiveCastTime,
        dps = dps,
        -- Flags
        isDot = spellData.isDot or false,
        isChanneled = spellData.isChanneled or false,
        -- DoT-specific
        tickDamage = expectedTick,
        numTicks = modResult.numTicks,
        duration = effectiveDuration,
    }
end

-------------------------------------------------------------------------------
-- BuildHybridResult — final result for hybrid spells (Immolate)
-------------------------------------------------------------------------------
function CritCalc.BuildHybridResult(modResult, spellData, critChance, critMultiplier, hitChance, effectiveCastTime)
    -- Direct portion benefits from crit
    local directDmg = modResult.directDamage
    local expectedDirect = directDmg * (1 + critChance * (critMultiplier - 1))

    -- DoT portion does not crit in TBC
    local dotDmg = modResult.dotDamage
    local tickDmg = modResult.tickDamage

    local expectedTotal = expectedDirect + dotDmg
    local expectedWithMiss = expectedTotal * hitChance

    -- Apply hit chance to individual components so the detailed display is accurate
    local directWithHit = expectedDirect * hitChance
    local dotWithHit = dotDmg * hitChance

    -- DPS: use cast time + DoT duration for hybrid total damage throughput
    -- This represents the total time investment (cast + ticking), giving a "total throughput DPS"
    -- rather than separate direct/DoT DPS values. This may differ from other addon displays.
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
        -- Base values
        avgBaseDamage = modResult.avgBaseDamage,
        coefficient = modResult.coefficient,
        spellPowerBonus = modResult.spellPowerBonus,
        -- Modifier values
        damageBeforeMods = modResult.damageBeforeMods,
        damageAfterMods = directDmg + dotDmg,
        talentDamageBonus = modResult.talentDamageBonus,
        -- Crit values
        critChance = critChance,
        critMultiplier = critMultiplier,
        expectedDamage = expectedTotal,
        -- Hit values
        hitChance = hitChance,
        expectedDamageWithMiss = expectedWithMiss,
        -- Timing
        castTime = effectiveCastTime,
        dps = dps,
        -- Flags
        isDot = true,
        isChanneled = false,
        -- Hybrid-specific
        directDamage = directWithHit,
        directSpBonus = modResult.directSpBonus,
        dotDamage = dotWithHit,
        dotSpBonus = modResult.dotSpBonus,
        tickDamage = dotWithHit / (modResult.numTicks or 1),
        numTicks = modResult.numTicks,
        duration = modResult.duration,
    }
end
