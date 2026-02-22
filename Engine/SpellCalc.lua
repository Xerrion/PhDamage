-------------------------------------------------------------------------------
-- SpellCalc.lua
-- Base damage computation: raw damage + spell power contribution
-- Pure Lua — no WoW API calls
--
-- Supported versions: TBC Anniversary
-------------------------------------------------------------------------------

local _, ns = ...

local SpellCalc = {}
ns.Engine.SpellCalc = SpellCalc

-------------------------------------------------------------------------------
-- GetCurrentRank(spellData, playerState)
-- Returns the highest rank the player can use based on level.
-- Returns: rankNumber, rankData  (or nil, nil if no rank qualifies)
-------------------------------------------------------------------------------
function SpellCalc.GetCurrentRank(spellData, playerState)
    local bestRank, bestData = nil, nil

    -- pairs used intentionally: handles sparse rank tables gracefully
    for rank, data in pairs(spellData.ranks) do
        if data.level <= playerState.level then
            if bestRank == nil or rank > bestRank then
                bestRank = rank
                bestData = data
            end
        end
    end

    return bestRank, bestData
end

-------------------------------------------------------------------------------
-- ComputeBase(spellData, rankData, playerState)
-- Computes raw damage values before talent/aura modifiers.
-- Returns an intermediate result table.
-------------------------------------------------------------------------------
function SpellCalc.ComputeBase(spellData, rankData, playerState)
    local spellType = spellData.spellType

    if spellType == "direct" then
        return SpellCalc.ComputeDirect(spellData, rankData, playerState)
    elseif spellType == "dot" then
        return SpellCalc.ComputeDot(spellData, rankData, playerState)
    elseif spellType == "hybrid" then
        return SpellCalc.ComputeHybrid(spellData, rankData, playerState)
    elseif spellType == "channel" then
        return SpellCalc.ComputeChannel(spellData, rankData, playerState)
    elseif spellType == "utility" then
        return SpellCalc.ComputeUtility(spellData, rankData, playerState)
    end

    return nil
end

-------------------------------------------------------------------------------
-- ComputeDirect — direct damage spells (Shadow Bolt, etc.)
-------------------------------------------------------------------------------
function SpellCalc.ComputeDirect(spellData, rankData, playerState)
    local avgBase = (rankData.minDmg + rankData.maxDmg) / 2

    if spellData.scalingType == "ranged" then
        return SpellCalc.ComputeRangedDirect(spellData, rankData, playerState, avgBase)
    elseif spellData.scalingType == "melee" then
        return SpellCalc.ComputeMeleeDirect(spellData, rankData, playerState)
    end

    local sp = playerState.stats.spellPower[spellData.school] or 0
    local spBonus = sp * (spellData.coefficient or 0)

    return {
        spellData = spellData,
        rankData = rankData,
        avgBaseDamage = avgBase,
        minBaseDamage = rankData.minDmg,
        maxBaseDamage = rankData.maxDmg,
        coefficient = spellData.coefficient,
        spellPowerBonus = spBonus,
        totalDamage = avgBase + spBonus,
        totalMin = rankData.minDmg + spBonus,
        totalMax = rankData.maxDmg + spBonus,
        castTime = spellData.castTime,
    }
end

-------------------------------------------------------------------------------
-- ComputeRangedDirect — ranged direct damage (Arcane Shot, Steady Shot, etc.)
-- Handles both simple RAP scaling and weapon-based formulas.
-------------------------------------------------------------------------------
function SpellCalc.ComputeRangedDirect(spellData, rankData, playerState, avgBase)
    local rap = playerState.stats.rangedAttackPower or 0
    local coefficient = spellData.coefficient or 0
    local rapBonus = rap * coefficient

    -- Weapon damage integration for spells like Steady Shot / Aimed Shot
    local weaponBonus = 0
    if spellData.weaponDamage then
        local weaponData = playerState.stats.weaponDamage
        if weaponData then
            local weaponAvg = (weaponData.min + weaponData.max) / 2
            weaponBonus = weaponAvg * (spellData.weaponMultiplier or 1)
        end
    end

    local totalDamage = avgBase + rapBonus + weaponBonus
    local totalMin = rankData.minDmg + rapBonus + weaponBonus
    local totalMax = rankData.maxDmg + rapBonus + weaponBonus

    return {
        spellData = spellData,
        rankData = rankData,
        avgBaseDamage = avgBase,
        minBaseDamage = rankData.minDmg,
        maxBaseDamage = rankData.maxDmg,
        coefficient = coefficient,
        spellPowerBonus = rapBonus,   -- re-use field name for display compatibility
        weaponBonus = weaponBonus,
        totalDamage = totalDamage,
        totalMin = totalMin,
        totalMax = totalMax,
        castTime = spellData.castTime,
    }
end

-------------------------------------------------------------------------------
-- ComputeMeleeDirect — melee direct damage (weapon strikes, AP-based, flat)
-- Three sub-types:
--   1. weaponDamage=true: weapon + normalized AP + flat bonus
--   2. apCoefficient: AP * coefficient (Bloodthirst-style)
--   3. neither: flat min/max from rank data (Thunder Clap-style)
-------------------------------------------------------------------------------
function SpellCalc.ComputeMeleeDirect(spellData, rankData, playerState)
    local stats = playerState.stats
    local ap = stats.attackPower or 0

    if spellData.weaponDamage then
        -- Type 1: Weapon strike — weapon damage + normalized AP + flat bonus
        local normalizedSpeed = ns.NORMALIZED_WEAPON_SPEED[stats.mainHandWeaponType] or 2.4
        local weaponMin = stats.mainHandWeaponDmgMin or 0
        local weaponMax = stats.mainHandWeaponDmgMax or 0
        local apBonus = ap / 14 * normalizedSpeed
        local flatBonus = rankData.minDmg or 0
        local weaponMult = spellData.weaponMultiplier or 1.0

        local minResult = (weaponMin + apBonus + flatBonus) * weaponMult
        local maxResult = (weaponMax + apBonus + flatBonus) * weaponMult
        local avgResult = (minResult + maxResult) / 2

        return {
            spellData = spellData,
            rankData = rankData,
            avgBaseDamage = avgResult,
            minBaseDamage = minResult,
            maxBaseDamage = maxResult,
            coefficient = 0,
            spellPowerBonus = 0,
            weaponBonus = 0,  -- weapon damage already included in base
            totalDamage = avgResult,
            totalMin = minResult,
            totalMax = maxResult,
            castTime = spellData.castTime,
        }

    elseif spellData.apCoefficient then
        -- Type 2: AP-based — AP * coefficient + optional base damage
        -- Bloodthirst-style (no base) and Eviscerate/Envenom-style (with base)
        local apDmg = ap * spellData.apCoefficient
        local baseMin = rankData.minDmg or 0
        local baseMax = rankData.maxDmg or 0
        local avgBase = (baseMin + baseMax) / 2
        return {
            spellData = spellData,
            rankData = rankData,
            avgBaseDamage = avgBase,
            minBaseDamage = baseMin,
            maxBaseDamage = baseMax,
            coefficient = spellData.apCoefficient,
            spellPowerBonus = apDmg,
            totalDamage = avgBase + apDmg,
            totalMin = baseMin + apDmg,
            totalMax = baseMax + apDmg,
            castTime = spellData.castTime,
        }

    else
        -- Type 3: Flat damage (Thunder Clap-style) — just rank min/max
        local avgBase = (rankData.minDmg + rankData.maxDmg) / 2
        return {
            spellData = spellData,
            rankData = rankData,
            avgBaseDamage = avgBase,
            minBaseDamage = rankData.minDmg,
            maxBaseDamage = rankData.maxDmg,
            coefficient = 0,
            spellPowerBonus = 0,
            totalDamage = avgBase,
            totalMin = rankData.minDmg,
            totalMax = rankData.maxDmg,
            castTime = spellData.castTime,
        }
    end
end

-------------------------------------------------------------------------------
-- ComputeDot — periodic damage spells (Corruption, Curse of Agony, etc.)
-------------------------------------------------------------------------------
function SpellCalc.ComputeDot(spellData, rankData, playerState)
    local scalingPower
    if spellData.scalingType == "ranged" then
        scalingPower = playerState.stats.rangedAttackPower or 0
    elseif spellData.scalingType == "melee" then
        local ap = playerState.stats.attackPower or 0
        local coefficient = spellData.coefficient or spellData.apCoefficient or 0
        local baseDmg = rankData.totalDmg or 0
        -- For melee bleeds with weapon scaling (like Rend)
        if spellData.weaponDotCoefficient then
            local weaponAvg = ((playerState.stats.mainHandWeaponDmgMin or 0)
                + (playerState.stats.mainHandWeaponDmgMax or 0)) / 2
            local normalizedDmg = weaponAvg
                + ap / 14 * (playerState.stats.mainHandWeaponSpeed or 2.4)
            baseDmg = baseDmg + spellData.weaponDotCoefficient * (rankData.numTicks or 1) * normalizedDmg
        end
        local spBonus = ap * coefficient
        local totalDmg = baseDmg + spBonus
        local numTicks = spellData.numTicks
        if not numTicks or numTicks == 0 then numTicks = 1 end
        local tickDmg = totalDmg / numTicks
        return {
            spellData = spellData,
            rankData = rankData,
            avgBaseDamage = baseDmg,
            coefficient = coefficient,
            spellPowerBonus = spBonus,
            totalDamage = totalDmg,
            tickDamage = tickDmg,
            numTicks = numTicks,
            duration = spellData.duration,
            castTime = spellData.castTime,
        }
    else
        scalingPower = playerState.stats.spellPower[spellData.school] or 0
    end
    local spBonus = scalingPower * (spellData.coefficient or 0)
    local totalDmg = rankData.totalDmg + spBonus
    local numTicks = spellData.numTicks
    if not numTicks or numTicks == 0 then numTicks = 1 end
    local tickDmg = totalDmg / numTicks

    return {
        spellData = spellData,
        rankData = rankData,
        avgBaseDamage = rankData.totalDmg,
        coefficient = spellData.coefficient,
        spellPowerBonus = spBonus,
        totalDamage = totalDmg,
        tickDamage = tickDmg,
        numTicks = numTicks,
        duration = spellData.duration,
        castTime = spellData.castTime,
    }
end

-------------------------------------------------------------------------------
-- ComputeHybrid — spells with both direct + DoT portions (Immolate)
-------------------------------------------------------------------------------
function SpellCalc.ComputeHybrid(spellData, rankData, playerState)
    local scalingPower
    if spellData.scalingType == "ranged" then
        scalingPower = playerState.stats.rangedAttackPower or 0
    elseif spellData.scalingType == "melee" then
        scalingPower = playerState.stats.attackPower or 0
    else
        scalingPower = playerState.stats.spellPower[spellData.school] or 0
    end

    -- Direct portion
    local directAvg = (rankData.minDmg + rankData.maxDmg) / 2
    local directSpBonus = scalingPower * (spellData.directCoefficient or 0)
    local directDamage = directAvg + directSpBonus

    -- DoT portion
    local dotSpBonus = scalingPower * (spellData.dotCoefficient or 0)
    local dotDamage = rankData.dotDmg + dotSpBonus
    local numTicks = spellData.numTicks
    if not numTicks or numTicks == 0 then numTicks = 1 end
    local tickDamage = dotDamage / numTicks

    return {
        spellData = spellData,
        rankData = rankData,
        -- Direct fields
        avgBaseDamage = directAvg,
        minBaseDamage = rankData.minDmg,
        maxBaseDamage = rankData.maxDmg,
        directCoefficient = spellData.directCoefficient,
        directSpBonus = directSpBonus,
        directDamage = directDamage,
        directMin = rankData.minDmg + directSpBonus,
        directMax = rankData.maxDmg + directSpBonus,
        -- DoT fields
        dotCoefficient = spellData.dotCoefficient,
        dotSpBonus = dotSpBonus,
        dotBaseDamage = rankData.dotDmg,
        dotDamage = dotDamage,
        tickDamage = tickDamage,
        numTicks = numTicks,
        duration = spellData.duration,
        -- Combined
        coefficient = (spellData.directCoefficient or 0) + (spellData.dotCoefficient or 0),
        spellPowerBonus = directSpBonus + dotSpBonus,
        totalDamage = directDamage + dotDamage,
        castTime = spellData.castTime,
    }
end

-------------------------------------------------------------------------------
-- ComputeChannel — channeled damage spells (Drain Life, Drain Soul, etc.)
-------------------------------------------------------------------------------
function SpellCalc.ComputeChannel(spellData, rankData, playerState)
    local scalingPower
    if spellData.scalingType == "ranged" then
        scalingPower = playerState.stats.rangedAttackPower or 0
    elseif spellData.scalingType == "melee" then
        scalingPower = playerState.stats.attackPower or 0
    else
        scalingPower = playerState.stats.spellPower[spellData.school] or 0
    end
    local spBonus = scalingPower * (spellData.coefficient or 0)
    local totalDmg = rankData.totalDmg + spBonus
    local numTicks = spellData.numTicks
    if not numTicks or numTicks == 0 then numTicks = 1 end
    local tickDmg = totalDmg / numTicks

    return {
        spellData = spellData,
        rankData = rankData,
        avgBaseDamage = rankData.totalDmg,
        coefficient = spellData.coefficient,
        spellPowerBonus = spBonus,
        totalDamage = totalDmg,
        tickDamage = tickDmg,
        numTicks = numTicks,
        duration = spellData.duration,
        castTime = spellData.castTime,
    }
end

-------------------------------------------------------------------------------
-- ComputeUtility — resource conversion spells (Life Tap)
-------------------------------------------------------------------------------
function SpellCalc.ComputeUtility(spellData, rankData, playerState)
    local scalingPower
    if spellData.scalingType == "ranged" then
        scalingPower = playerState.stats.rangedAttackPower or 0
    elseif spellData.scalingType == "melee" then
        scalingPower = playerState.stats.attackPower or 0
    else
        scalingPower = playerState.stats.spellPower[spellData.school] or 0
    end
    local spBonus = scalingPower * (spellData.coefficient or 0)
    local manaGain = rankData.manaGain + spBonus

    return {
        spellData = spellData,
        rankData = rankData,
        coefficient = spellData.coefficient,
        spellPowerBonus = spBonus,
        healthCost = rankData.healthCost,
        manaGain = manaGain,
        castTime = spellData.castTime or 0,
    }
end
