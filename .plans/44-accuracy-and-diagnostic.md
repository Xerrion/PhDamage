---
status: READY_FOR_REVIEW
phase: 1
updated: 2026-04-29
issue: Xerrion/PhDamage#44
branch: fix/44-accuracy-and-diagnostic
---

# PhDamage Accuracy + Diagnostic Plan

## Goal

Fix two engine bugs that together explain a ~5–10% systematic overestimate in PhDamage's expected-damage display, and add a diagnostic slash subcommand to investigate the Hellfire missing-overlay report without speculative engine changes. Single PR closing issue #44.

## Context & Decisions

| Decision | Rationale | Citation |
|---|---|---|
| Per-entry audit + remove school-wide CRIT_BONUS duplicates | User-confirmed approach. Verified by `wow-addon` agent against TBC Wowpedia/Wowhead for all 35 entries. | ref:ses_2274fc5b8ffe4UiHDpeeY7ue1E |
| Final verdict: 18 REMOVE, 17 KEEP, 0 INCONCLUSIVE | Ground truth from per-talent Wowpedia/Wowhead TBC citations. Initial blind audit had over-removed 7 entries (Devastation spans Shadow+Fire as a Destruction-tree subset; Tidal Mastery and Call of Thunder are per-spell lists not Nature-school-wide). User's pushback was correct. Sanctified Seals resolved post-pushback as universal +crit per verbatim TBC tooltip. | ref:ses_2274fc5b8ffe4UiHDpeeY7ue1E + ref:ses_2274201d0ffe0wZpXcCAWqLMIh |
| Single umbrella PR for Bugs A, B, C closing #44 | User-confirmed. Three fixes are independent in code but share one accuracy story; CodeRabbit handles the surface area; one history entry for the investigation. | User answer (m0006) |
| PhDamage models current player state only (current weapon/form) | User-confirmed. This makes weapon/form-conditional auras (Sharpened Claws, Dagger Spec, Fist Weapon Spec, Poleaxe Spec) safe to REMOVE because the API includes them when condition holds. | Earlier user answer |
| Combat Expertise (Paladin) removed as data bug, not double-count | TBC 2.5.4 tooltip grants Expertise + Stamina; +crit was added in Wrath 3.1.0. Entry is plain wrong for TBC. | Wowpedia citation in audit table |
| Sanctified Seals (Paladin 3:21) → REMOVE (universal +crit chance) | Verbatim TBC 2.5.x tooltip from Wowhead spell=35395/35396/35397: "Increases your chance to critically hit with all spells and melee attacks by N%..." Universal scope, reflected in `GetSpellCritChance(any school)` and `GetCritChance()`. Resolved in-plan. | ref:ses_2274201d0ffe0wZpXcCAWqLMIh |
| Sanctified Seals comment cleanup (no code/key change) | TalentMap key is `"3:21"` (correct per current source). Comment says "Retribution 3:21" but Wowpedia places it in Holy tree Tier 7. PhDamage uses `tab:index` keying with no spellID dependency, so REMOVE alone is sufficient. Coder must verify `tab:index` mapping convention against existing Paladin tabs before deletion - if `3` is Retribution in PhDamage's convention, the comment is right and Wowpedia uses different tab numbering. | Source verification at TalentMap_Paladin.lua L121, L135-142 |
| 0 missing per-spell crit talents to ADD | All 9 TBC class trees walked; every per-spell or per-spell-list crit-chance talent is already in TalentMap files. | ref:ses_2274fc5b8ffe4UiHDpeeY7ue1E Table 2 |
| Linear stack scaling via `maxStacks` field on AuraMap entry | User-confirmed approach. Mirrors existing Sunder Armor pattern in `Core/StateCollector.lua:81-97` (`ARMOR_DEBUFFS[id].maxStacks` × `auraData.applications`). | ref:ses_22756df6fffesK7pohCP6Kfr0J |
| Plumb stacks through StateCollector → ModifierCalc | Currently `state.auras.<scope>[spellID] = true` discards `auraData.applications`. Change value to `applications or 1` so consumers can read it. Producer change at 3 call sites in `Core/StateCollector.lua` (L407, L421, L437); consumer change at `ApplyAuraEntry` and `ApplyEffect` call sites in `Engine/ModifierCalc.lua`. | ref:ses_22756df6fffesK7pohCP6Kfr0J |
| `ApplyAuraEntry` signature gains `applications` parameter | Currently doesn't know which spellID it came from. Caller (the iteration at `ModifierCalc.lua:281` and `:287`) can pass the value from `playerState.auras.<scope>[spellID]`. Cleaner than re-looking-up inside the callee. | ref:ses_22756df6fffesK7pohCP6Kfr0J |
| Backwards compatible: entries without `maxStacks` behave as today | Existing AuraMap entries (Curse of Elements, Misery, etc.) don't have stack semantics; treating them as `maxStacks = 1` would break nothing but adds noise. Skip the multiplier when `entry.maxStacks` is nil. | Engineering judgment |
| `/phd debug` defaults to bar-wide dump of slots 1-12 | User-confirmed approach. Empty slots skipped. `/phd debug <slot>` for single slot. Output is plain `print()`, no UI. | User answer |
| Diagnostic command lives in `Presentation/Diagnostics.lua` | Existing module already owns `PrintState`/`PrintAll`/`PrintSpell`. New `PrintDebug(slot?)` follows the established naming pattern. Routed from `Core/Init.lua:OnSlashCommand`. | ref:ses_22756df6fffesK7pohCP6Kfr0J |
| No speculative Hellfire fix in this PR | Static analysis ruled out data, engine, and presentation skip paths. Direct-spell-drag rules out the macro theory. Root cause requires runtime data; speculation risks shipping a non-fix. | Earlier user decision (m0055) |
| Defer partial-resist modeling | At ~5-10% gap, crit double-count + stack scaling almost certainly account for the bulk. Adding average partial-resist could swing into UNDER-estimate after the other fixes land. File as follow-up only if data warrants. | Earlier user decision (m0055) |

## Design

### Bug A: Crit double-count fix

**Mechanism:** `Core/StateCollector.lua:202-207` reads `GetSpellCritChance(school)` per school into `playerState.stats.spellCrit[school]`. The WoW API value already reflects passive talents that grant school-wide spell crit, global all-spell crit, weapon-conditional melee crit (when the weapon is wielded), and form-conditional crit (when in form). `Engine/ModifierCalc.lua:194` then adds `mods.critBonus` (sourced from TalentMap `MOD.CRIT_BONUS` entries) into the same crit. Talents reflected in the API are counted twice.

**Fix:** REMOVE the 18 entries below per the verified audit. Single edit pass across 9 TalentMap files. No engine changes - the engine semantic is correct, the data is wrong.

**Decision rule used in the audit:**
- REMOVE if school-wide, global, weapon-conditional (with the weapon currently equipped per "current state only" semantic), or form-conditional. All these are reflected in `GetSpellCritChance(school)`, `GetCritChance()`, or `GetRangedCritChance()`.
- KEEP if the talent grants crit only to a strict subset of named spells within a school (not encodable in the per-school API scalar) OR spans multiple schools as a tree-defined list (Devastation crosses Shadow+Fire as a Destruction-tree subset).

**Audit (18 REMOVE, 17 KEEP, 0 INCONCLUSIVE):**

REMOVE rows:

| File | Talent | Per-rank | Rationale |
|---|---|---|---|
| `Data/TalentMap_Druid.lua` | Sharpened Claws | +2% | Form aura active in Cat/Bear; in `GetCritChance()` while in form |
| `Data/TalentMap_Druid.lua` | Natural Perfection | +1% | All spells universal; in `GetSpellCritChance()` for every school |
| `Data/TalentMap_Hunter.lua` | Lethal Shots | +1% | Ranged-wide; in `GetRangedCritChance()` |
| `Data/TalentMap_Hunter.lua` | Survival Instincts | +2% | Melee+ranged; in both `GetCritChance()` and `GetRangedCritChance()` |
| `Data/TalentMap_Mage.lua` | Arcane Instability | +1% | **CRIT_BONUS effect only.** DAMAGE_MULTIPLIER effect on the same talent stays. |
| `Data/TalentMap_Mage.lua` | Critical Mass | +2% | Whole Fire school; in `GetSpellCritChance(SCHOOL_FIRE)` |
| `Data/TalentMap_Mage.lua` | Pyromaniac | +1% | Whole Fire school |
| `Data/TalentMap_Paladin.lua` | Holy Power | +1% | Whole Holy school; in `GetSpellCritChance(SCHOOL_HOLY)` |
| `Data/TalentMap_Paladin.lua` | Combat Expertise | (none) | **Data bug.** TBC tooltip grants Expertise + Stamina, NOT crit. Crit was added in Wrath 3.1.0. Delete entry entirely. |
| `Data/TalentMap_Paladin.lua` | Sanctified Seals (3:21) | +1% | Universal +crit per TBC tooltip (Wowhead spell=35395/35396/35397). Reflected in every `GetSpellCritChance(school)` and `GetCritChance()`. **Coder must verify the comment "Retribution 3:21" against PhDamage's tab numbering convention** - Wowpedia places this talent in Holy Tier 7. The `tab:index` key stays as `"3:21"` per existing source; only the entry body is removed. |
| `Data/TalentMap_Priest.lua` | Holy Specialization | +1% | Whole Holy school |
| `Data/TalentMap_Priest.lua` | Force of Will | +1% | **CRIT_BONUS effect only.** DAMAGE_MULTIPLIER effect stays. |
| `Data/TalentMap_Rogue.lua` | Malice | +1% | Melee-wide; in `GetCritChance()` |
| `Data/TalentMap_Rogue.lua` | Dagger Specialization | +1% | Weapon aura while wielding daggers; in `GetCritChance()`. Delete the obsolete `weaponType filter` TODO comment. |
| `Data/TalentMap_Rogue.lua` | Fist Weapon Specialization | +1% | Same as Dagger Spec. Delete obsolete TODO. |
| `Data/TalentMap_Warlock.lua` | Demonic Tactics | +1% | All spells + melee universal |
| `Data/TalentMap_Warlock.lua` | Backlash | +1% | All spells universal per TBC tooltip ("with all spells"). Existing "no school filter" comment confirms. |
| `Data/TalentMap_Warrior.lua` | Poleaxe Specialization | +1% | Weapon aura while wielding axe/polearm; in `GetCritChance()`. Delete obsolete TODO. |
| `Data/TalentMap_Warrior.lua` | Cruelty | +1% | Melee-wide; in `GetCritChance()` |

KEEP rows (no changes; documented for completeness):

| File | Talent | Per-rank | Reason kept |
|---|---|---|---|
| `Data/TalentMap_Druid.lua` | Improved Moonfire | +5% | Single spell |
| `Data/TalentMap_Druid.lua` | Focused Starlight | +2% | Spell list (Wrath, Starfire) |
| `Data/TalentMap_Druid.lua` | Improved Regrowth | +10% | Single spell |
| `Data/TalentMap_Mage.lua` | Arcane Impact | +2% | Spell list (Arcane Explosion, Arcane Blast) |
| `Data/TalentMap_Mage.lua` | Improved Flamestrike | +5% | Single spell |
| `Data/TalentMap_Mage.lua` | Incineration | +2% | Spell list (Fire Blast, Scorch) - subset of Fire |
| `Data/TalentMap_Mage.lua` | Empowered Frostbolt | +1% | Single spell |
| `Data/TalentMap_Paladin.lua` | Sanctified Light | +2% | Spell list (Holy Light, Flash of Light) |
| `Data/TalentMap_Paladin.lua` | Purifying Power | +10% | Spell list (Exorcism, Holy Wrath) |
| `Data/TalentMap_Rogue.lua` | Puncturing Wounds | +10%/+5% | Single spells (Backstab, Mutilate) |
| `Data/TalentMap_Rogue.lua` | Improved Ambush | +15% | Single spell |
| `Data/TalentMap_Shaman.lua` | Call of Thunder | +1% | Spell list (Lightning Bolt, Chain Lightning) - subset of Nature |
| `Data/TalentMap_Shaman.lua` | Tidal Mastery | +1% | Spell list (Lightning + healing) - subset of Nature |
| `Data/TalentMap_Warlock.lua` | Improved Searing Pain | +4/+7/+10% | Single spell, non-linear ranks |
| `Data/TalentMap_Warlock.lua` | Devastation | +1% | **Tree subset spans Shadow+Fire.** Cannot be encoded by any single `GetSpellCritChance(school)` because the talent crosses school boundaries. KEEP. |
| `Data/TalentMap_Warrior.lua` | Improved Overpower | +25% | Single spell |

**INCONCLUSIVE:** None. Sanctified Seals resolved to REMOVE in this PR per user direction; verbatim TBC tooltip from Wowhead spell=35395/35396/35397 confirms universal `+N% crit with all spells and melee attacks`.

**Out of scope (correctly KEEP, not in audit):** All `MOD.CRIT_MULT_BONUS` entries (Vengeance, Mortal Shots, Lethality, Predatory Instincts, Spell Power, Ice Shards, Shadow Power, Impale, Ruin, Elemental Fury). These affect crit *damage multiplier*, not crit *chance*. Not in `GetSpellCritChance()` / `GetCritChance()`. Verified.

**Risk:** With Devastation, Tidal Mastery, Call of Thunder kept (they were previously flagged for removal in the leaning audit), the spell-crit modeling for Warlock Destro and Shaman Elemental will be slightly more conservative than a "remove everything that smells school-wide" pass. This is the correct conservative direction - the API genuinely cannot encode tree-subset talents.

### Bug B: Stack-aware aura modifiers

**Producer changes** (`Core/StateCollector.lua`):

| Line | Current | New |
|---|---|---|
| 407 | `state.auras.player[spellID] = true` | `state.auras.player[spellID] = auraData.applications or 1` |
| 421 | `state.auras.player[spellId] = true` | `state.auras.player[spellId] = auraData.applications or 1` |
| 437 | `state.auras.target[spellId] = true` | `state.auras.target[spellId] = auraData.applications or 1` |

The stack count for non-stacking auras is `1` per the Blizzard API contract, so consumers that don't care about stacks (the truthy check in existing code) keep working.

**Consumer changes** (`Engine/ModifierCalc.lua`):

The two iteration sites at `:281` and `:287` (player and target aura loops) need to pass the new stack count into `ApplyAuraEntry`. Signature:

```
-- before
local function ApplyAuraEntry(entry, spellData, rankData, playerState, mods)
-- after
local function ApplyAuraEntry(entry, spellData, rankData, playerState, mods, applications)
```

Inside `ApplyAuraEntry`, compute the stack factor when the entry declares `maxStacks`:

```
local stackFactor = 1
if entry.maxStacks and entry.maxStacks > 0 then
    local stacks = applications or 1
    if stacks > entry.maxStacks then stacks = entry.maxStacks end
    stackFactor = stacks / entry.maxStacks
end
```

Pass `stackFactor` to `ApplyEffect` (signature gains a 5th arg, default 1) which multiplies the resolved `value` by it. Same treatment for the `talentAmplify` branch at `:241`.

**Data changes** (`Data/AuraMap_Warlock.lua`):

| Line | Aura | Change |
|---|---|---|
| 157-164 | Shadow Vulnerability (17800/17803) | Add `maxStacks = 5`; change `value = 0.20` → `value = 0.20` (kept; final per-stack delivered via `stackFactor` × declared total). Update the L156 comment to remove "assumes 5 stacks" note. |
| 266-273 | Shadow Weaving (15258) | Add `maxStacks = 5`; keep `value = 0.10` (final-stack value). Update the L265 comment. |

**Semantic note on the value:** The user-facing schema is "value = bonus at MAX stacks". The engine scales it down by `applications / maxStacks`. An aura at 1/5 stacks delivers `0.20 × (1/5) = 0.04` (the per-stack ISB value). At 5/5: `0.20 × (5/5) = 0.20` (unchanged from today). This means **no test that exercises an at-max-stack scenario regresses** — the only behavior change is when `applications < maxStacks`.

**Backward compatibility:** Entries without `maxStacks` skip the scaling block entirely. All existing AuraMap entries across all classes continue to behave as today.

**Other class AuraMap files:** Audit `Data/AuraMap_*.lua` for other stacking debuffs/buffs that should adopt `maxStacks`:

- Misery (33196/33198/33199): TBC Misery is non-stacking (3% spell hit + 5% spell damage flat). Skip.
- Improved Scorch (12873): 5-stack +15% fire damage taken. **Add `maxStacks = 5`.** Mage AuraMap.
- Sunder Armor: handled separately in StateCollector for armor reduction; not in any AuraMap.
- Curse of Recklessness, Curse of Elements/Shadow: non-stacking. Skip.

The Improved Scorch addition is in scope. Audit any other class AuraMap files for explicit "5 stacks" or "3 stacks" comments and bring them under the same pattern. Coder is to do this audit pass and report what they found in the PR description.

### Diagnostic: `/phd debug [slot]`

**Routing** (`Core/Init.lua:101-106` insertion point):

Add a new `elseif cmd == "debug" then` branch after the `config` branch and before `help`. Body:

```
elseif cmd == "debug" then
    local slot = tonumber(args[2])
    ns.Diagnostics.PrintDebug(slot)
```

When `slot` is nil, `PrintDebug` iterates 1..12. When `slot` is a number, single-slot.

Add a help line in the `help` branch (between L112 and L113):

```
self:Print("  /phd debug [slot] - Diagnose action slot (default: bar 1-12)")
```

**Implementation** (`Presentation/Diagnostics.lua`, new public function):

```
function Diagnostics.PrintDebug(slot)
    if slot then
        DumpSlot(slot)
        return
    end
    for i = 1, 12 do
        DumpSlot(i)
    end
end
```

`DumpSlot(i)` prints (one slot per chat block, separated by a thin rule):

1. Slot index header
2. `GetActionInfo(i)` → `actionType, id, subType` raw return
3. If actionType is `"spell"`: pass `id` to `ns.ActionBar.ResolveSpellID` (or its internal equivalent — read the actual function name) and print result
4. If actionType is `"macro"`: call `GetMacroSpell(id)` and print result, then attempt resolution
5. Spell data lookup: `ns.SpellData[resolvedID]` → present / absent (and base ID if mapped via `BuildSpellIDMap`)
6. If present: call `ns.Engine.Pipeline.Calculate(resolvedID, ns.StateCollector.GetState())` and print whether it returned a result, the `expectedDamageWithMiss`, and any skip reason
7. Empty slots: print `slot N: empty` and continue

The exact internal API names need verification by the coder against current source; the structure above is the goal.

## Phases

### Phase 1: Bug A — crit double-count [PENDING]

- 1.1 Touch each TalentMap_*.lua file per the REMOVE table; delete the offending entry blocks (the table-assignment to `TalentMap["tab:index"]` and the comment line above it). Where a TODO comment for weapon-type filtering accompanied an entry (Rogue Dagger/Fist Spec, Warrior Poleaxe Spec), delete the TODO too. For Sanctified Seals (`TalentMap_Paladin.lua` `["3:21"]`), additionally verify and correct the tab-name comment on L121/L135 if PhDamage's tab numbering disagrees with Wowpedia (Holy = Tier 7 per Wowpedia; comment currently says "Retribution"). KEEP entries are not modified. ← CURRENT
- 1.2 Add busted regression test `tests/test_crit_double_count.lua`: build a player state with `spellCrit[SCHOOL_FIRE] = 0.10` (simulating "API already includes Pyromaniac"), apply a Mage talent map with `Pyromaniac` rank 3, assert `mods.critBonus == 0` (i.e., the engine no longer adds talent crit on top).
- 1.3 Run `busted --verbose` from `F:\wow-addons\PhDamage`. All existing tests must continue to pass — the audit promises that REMOVE entries don't affect non-crit math, but verification is required.

### Phase 2: Bug B — stack-aware modifiers [PENDING]

- 2.1 `Core/StateCollector.lua`: change 3 aura assignments from `= true` to `= auraData.applications or 1`. Verify no other consumer relies on the boolean shape (grep for `state.auras.target[` and `state.auras.player[`).
- 2.2 `Engine/ModifierCalc.lua`: extend `ApplyAuraEntry` signature with `applications`; compute `stackFactor` when `entry.maxStacks`; pass to `ApplyEffect`. Extend `ApplyEffect` signature with optional `stackFactor` (default 1); multiply resolved `value` by it. Update both iteration call sites to pass the per-spell stack count.
- 2.3 `Data/AuraMap_Warlock.lua`: add `maxStacks = 5` to Shadow Vulnerability and Shadow Weaving entries; clean up the "assumes 5 stacks" comments.
- 2.4 `Data/AuraMap_Mage.lua` (and other class files as applicable): audit for stacking auras, add `maxStacks` where appropriate (Improved Scorch is the known case). Coder reports findings in PR description.
- 2.5 Add busted tests in `tests/test_stack_scaling.lua`: scenarios for Shadow Vulnerability at 1, 3, 5 stacks; assert resulting damage multiplier is 0.04, 0.12, 0.20 respectively. Same shape for Shadow Weaving and Improved Scorch.
- 2.6 Run `busted --verbose`. Existing tests that exercise these auras must continue to pass — they do today because the implicit assumption is "max stacks = full bonus", which the new code preserves at max stacks.

### Phase 3: `/phd debug` diagnostic [PENDING]

- 3.1 `Presentation/Diagnostics.lua`: add `Diagnostics.PrintDebug(slot)` and the file-local `DumpSlot(i)` helper per the design above. Verify the actual `ResolveSpellID` and pipeline entrypoint names against current source before writing.
- 3.2 `Core/Init.lua`: add `debug` branch to `OnSlashCommand` dispatcher; add help line.
- 3.3 No tests for this path (it's a chat-print diagnostic; tests would just assert print formatting). Manual verification only.

### Phase 4: Verification + ship [PENDING]

- 4.1 `luacheck .` from repo root → 0 warnings / 0 errors.
- 4.2 `busted --verbose` → all tests green (existing + 2 new test files).
- 4.3 Reviewer pass (mandatory per workflow). Address BLOCKERS, fix WARNINGS, note NOTEs.
- 4.4 Commit with conventional message referencing `Closes #44`. Push branch.
- 4.5 Open PR, conform to repo PULL_REQUEST_TEMPLATE.md. PR body summarizes the audit table, the stack-scaling semantics change, and the new diagnostic command. Note explicit deferrals (Hellfire fix, partial resists).
- 4.6 Wait for CI green + CodeRabbit review. Address CodeRabbit findings via `@coderabbitai` replies on the specific threads.
- 4.7 Hand off to owner for squash-merge (not auto-merged per workspace AGENTS.md).

## Verification

- `luacheck .` = 0/0
- `busted --verbose` = all green, with 2 new test files (`test_crit_double_count.lua`, `test_stack_scaling.lua`) added
- New regression tests fail before the fix and pass after (verify by stashing the engine/data changes and running tests against the new spec files)
- Manual in-game smoke test (post-merge, by user): `/phd debug` prints structured per-slot info on a Warlock; expected damage on Shadow Bolt with 5/5 Devastation and Ruin no longer inflates by ~5% relative to actual; Shadow Bolt overlay value scales correctly as ISB stacks build from 1 to 5

## Out of Scope (explicit)

- Speculative Hellfire fix (deferred until `/phd debug` produces runtime data)
- Average partial-resist model
- Hellfire / Rain of Fire / Drain Soul coefficient re-derivation
- Sustained-DPS execution-efficiency multiplier (movement, clipping, latency)
- AuraMap `talentAmplify` interaction with stack-scaling — current entries don't combine the two; flag in code with a comment but don't engineer for it speculatively

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| A KEEP talent is actually in the API → still over-reports for that class | Low | Low (per-talent ~1-3%) | Conservative KEEP rule (strict subset only); follow-up audit if user reports persist |
| Removing a TalentMap entry breaks a non-crit test (e.g. shared talent block with damage bonus) | Low | Medium | Run full busted before commit; verify each REMOVE is a standalone entry, not a shared talent block |
| `state.auras.<x>[id] = applications` value change breaks a code path that did `if state.auras.target[id] then` | Very Low | Medium | All known consumers use truthy checks which still work for `>= 1`. Grep for explicit `== true` comparisons before merging. |
| `ApplyAuraEntry` signature change breaks an out-of-tree caller | Very Low | Low | Internal function only; no public API surface |
| `/phd debug` reveals Hellfire root cause is something we should have fixed in this PR | Medium | Low | Acceptable — file follow-up issue with the captured diagnostic output, fix in a small targeted PR |
