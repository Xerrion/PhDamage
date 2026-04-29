---
status: not-started
phase: 1
updated: 2026-04-29
---

# Implementation Plan: Engine Accuracy BLOCKERs (#46, #47)

## Goal
Bring PhDamage's TBC spell-power math in line with cMaNGOS-TBC by correcting AoE coefficient data per #46 and modeling the downranking level penalty per #47, with green tests gating each phase.

## Context & Decisions

| Decision | Rationale | Source |
|----------|-----------|--------|
| Store post-penalty empirical coefficients in SpellData (no runtime AoE multiplier) | Matches cMaNGOS-TBC `SpellMgr::CalculateDefaultCoefficient` convention; avoids double-applying penalties; matches existing OK entries (Arcane Explosion 0.213, Holy Nova 0.161) | `ref:audit-aoe-research` |
| TBC AoE rule is x 1/2, not x 1/3 (vanilla) | WoWWiki Spell_power archive (oldid=1549180, July 2008 / patch 2.4.3 era): "AoE spells receive only 1/2 of the total bonus"; patch 2.2.0 notes raised Hellfire/Blizzard/RoF coefficients consistent with relaxation | `ref:audit-aoe-research` |
| Use per-spell empirical values from WoWWiki July 2008 table, not formula recomputation | Secondary penalties (Hurricane 0.9 slow, Cone of Cold 0.633 snare) stack non-uniformly; formula `Cast/7` gives wrong answers for spells with secondary modifiers | `ref:audit-aoe-research` |
| Hellfire splits into two coefficient paths: 142.86% (self-channel) vs 214.29% (enemy AoE) | Empirically distinct in WoWWiki table; current single-coefficient entry conflates both | `ref:audit-aoe-research` |
| Volley loses SP scaling entirely | Hunter ranged spell scales from ranged AP only, not spell power | `ref:audit-aoe-research` |
| Downranking formula: `(MaxLevel + 6) / playerLevel` x sub-20 multiplier with top-rank exemption | cMaNGOS-TBC `Unit.cpp:2920-2936 CalculateLevelPenalty` is canonical for TBC 2.5.4; AzerothCore uses `SpellLevel + 6` but diverges from Blizzard's 2005 blue post and cMaNGOS-TBC | `ref:audit-downrank-research` |
| Apply penalty to SP bonus only, not base damage | Matches emulator behavior; base damage is rank-intrinsic | `ref:audit-downrank-research` |
| New module `Engine/LevelPenalty.lua` (pure Lua) | Engine purity rule per `PhDamage/AGENTS.md` - no WoW API calls in Engine/ | PhDamage AGENTS.md |
| `maxLevel` field added per-rank in SpellData (declarative, no functions) | Data layer purity rule - declarative tables only | PhDamage AGENTS.md |
| Top-rank `maxLevel = spellLevel` to trigger `spellLevel >= maxLevel` exemption | Matches cMaNGOS-TBC short-circuit at line 2924 | `ref:audit-downrank-research` |
| Channel haste claim REJECTED, not in scope | Verification confirmed `Engine/SpellCalc.lua:324-351` and `CritCalc.lua:233-298` match cMaNGOS-TBC exactly; existing `tests/test_haste.lua` already encodes the contract and passes | `ref:audit-haste-verify` |
| Sequence #46 before #47 | #47's per-rank regression tests benefit from corrected AoE data; both touch SpellData_*.lua so serializing avoids merge friction | this plan |

References:
- `ref:audit-aoe-research` -> WoWWiki Spell_power archive + Spell_power_coefficient archive (oldid=1549180) + cMaNGOS-TBC SpellMgr.cpp:316-334
- `ref:audit-downrank-research` -> cMaNGOS-TBC Unit.cpp:2920-2936 + Blizzard 2005 BlueTracker post + Vanilla wiki Downranking + Schlemiel-10753 EU forum 2026-01-14
- `ref:audit-haste-verify` -> debugger review of Engine/SpellCalc.lua:324-351 + Engine/CritCalc.lua:233-298 vs cMaNGOS-TBC SpellAuras.cpp:385-393

## Phase 1: AoE Coefficient Corrections (#46) [PENDING]

Pure data work. No engine code changes.

- [ ] **1.1 Branch `fix/46-aoe-coefficients` from master** ← CURRENT
- [ ] 1.2 Add canonical-coefficient policy comment to header of every `Data/SpellData_*.lua` file (post-penalty storage convention; do NOT divide at runtime)
- [ ] 1.3 Audit Mage AoE entries: Blizzard 0.952 -> 0.762 total (~9.52%/tick), Arcane Explosion 0.213 (verify - already OK), Cone of Cold (verify against 13.57% target)
- [ ] 1.4 Audit Druid AoE entries: Hurricane 1.07 -> 1.28 total (12.8%/tick, with 0.9 slow penalty baked in)
- [ ] 1.5 Audit Warlock AoE entries: Rain of Fire 0.57 -> 0.952 total (23.81%/tick); split Hellfire into two entries or hybrid encoding (142.86% self-channel + 214.29% enemy AoE); audit Seed of Corruption 0.2286 and Shadowfury 0.193
- [ ] 1.6 Audit Hunter AoE entries: remove SP scaling from Volley (set scaling-disabled flag or remove coefficient); confirm ranged-AP-only path
- [ ] 1.7 Audit Paladin AoE entries: Consecration -> 95.24% total (~11.9%/tick if not already)
- [ ] 1.8 Audit Priest AoE entries: Holy Nova damage 0.161 (verify - already OK)
- [ ] 1.9 Audit remaining classes (Shaman, Warrior, Rogue) for any AoE entries needing corrections
- [ ] 1.10 Add inline citation comments for non-obvious values: Hurricane 0.9 slow, Cone of Cold 0.633 snare, Hellfire split paths
- [ ] 1.11 Add unit tests in `tests/test_aoe_coefficients.lua` asserting expected total damage at known SP values for each corrected spell
- [ ] 1.12 Run `luacheck .` (zero new warnings) and `busted --verbose` (all green)
- [ ] 1.13 Open PR `Closes #46`; address CodeRabbit and reviewer feedback; squash merge

## Phase 2: Downranking Penalty Engine + Data (#47) [PENDING]

Engine module + per-rank data plumbing.

- [ ] 2.1 Branch `feat/47-downranking-penalty` from master (after #46 merges)
- [ ] 2.2 Create `Engine/LevelPenalty.lua` (pure Lua, namespace `ns.Engine.LevelPenalty`) exporting `CalculateLevelPenalty(spellLevel, maxLevel, playerLevel)` matching cMaNGOS-TBC formula exactly
- [ ] 2.3 Add `Engine/LevelPenalty.lua` to `PhDamage.toc` in correct load order (before ModifierCalc)
- [ ] 2.4 Write `tests/test_levelpenalty.lua` covering: top-rank exemption (`spellLevel >= maxLevel`), sub-20 stacking ((20-x)*3.75), MaxLevel+6 numerator, LvlFactor cap at 1.0, healing path, channel path, DoT path. Include the four worked examples from #47 (Frostbolt R11, Frostbolt R3, Greater Heal R1, Shadow Bolt R5)
- [ ] 2.5 Plumb `maxLevel` field into per-rank entries across all 9 `SpellData_*.lua` files. Convention: `maxLevel = nextRankLevel - 1` for non-top ranks; `maxLevel = level` for top ranks (triggers exemption)
- [ ] 2.6 Source maxLevel values from Wowhead TBC Classic via `wowhead-researcher` agent for any ambiguous rank levels
- [ ] 2.7 Modify `Engine/ModifierCalc.lua::BuildModifiedResult` (line ~355) to apply `LevelPenalty.CalculateLevelPenalty(rankData.level, rankData.maxLevel, playerState.level)` to `effectiveSp * effectiveCoeff` (the SP bonus), not base damage. Same edit at the hybrid path (~line 441) and utility path (~line 360)
- [ ] 2.8 Add equivalent SP-bonus penalty application for healing path when W4 lands separately (note in code comment that healing currently routes through spellPower; revisit when W4 closes)
- [ ] 2.9 Update `Engine/Pipeline.lua::CalculateAll` to iterate per-rank for headline diagnostics (resolves N1 from issue #49 via the same PR or separate follow-up - prefer same PR for atomicity)
- [ ] 2.10 Add regression tests in `tests/test_pipeline.lua` calling `Calculate(spellID, state, lowerRankIndex)` at L70 for Frostbolt R3 (effective coeff ~0.2035), Greater Heal R1 (~0.7286), Shadow Bolt R5 (~0.5857)
- [ ] 2.11 Verify no existing test regressions: `tests/test_modifiercalc.lua`, `test_spellcalc.lua`, `test_critcalc.lua`, all class spell tests must stay green
- [ ] 2.12 Run `luacheck .` and `busted --verbose`
- [ ] 2.13 Open PR `Closes #47`; address CodeRabbit and reviewer feedback; squash merge

## Phase 3: Wrap-up [PENDING]

- [ ] 3.1 Update `.plans/engine-accuracy-blockers.md` status to `complete` after both PRs merge
- [ ] 3.2 Add forensic note to `.plans/audit-corrections.md` documenting that the original audit had two formula errors (channel haste false positive; downranking formula off by `(rank+11)/PL` vs correct `(MaxLevel+6)/PL`) so future audits don't re-cite the wrong formulas
- [ ] 3.3 Triage warnings (#48) and notes (#49) trackers next - separate planning cycle
- [ ] 3.4 Cross-link merged PRs back to issues #46 and #47

## Out of Scope

- Channel haste rework - REJECTED, code already correct (`ref:audit-haste-verify`)
- Partial resist modeling (W8) - deferred per #44
- AoE damage cap mechanic (patch 2.2.0+ separate system) - separate issue if pursued
- W1-W9 warning fixes (covered by #48)
- N1-N6 note polish (covered by #49), except N1 which closes naturally with task 2.9

## Risk & Mitigation

| Risk | Mitigation |
|------|-----------|
| Wowhead/WoWWiki numbers disagree on a specific spell coefficient | Cite the WoWWiki July 2008 archive as primary; flag conflict in PR description for reviewer |
| `maxLevel` plumbing causes nil deref on un-migrated entries during incremental rollout | `LevelPenalty.CalculateLevelPenalty` returns 1.0 when `maxLevel == nil` (defensive); add luacheck-grade assertion in tests that all SpellData entries have maxLevel set before merging #47 |
| Hellfire split breaks existing tooltip/diagnostics consumers | Audit `Presentation/` and `Diagnostics/` for assumptions about single Hellfire entry before splitting; may need keyed-by-school differentiation |
| Per-rank Pipeline iteration explodes diagnostics output | Gate per-rank iteration behind a flag; default to highest-rank-only for action-bar UI; expose lower ranks only via explicit slash command |
| Downranking penalty changes break high-rank spell tests by accident | All top-rank tests should be unaffected (exemption returns 1.0); CI-level regression coverage on existing `test_*_spells.lua` is the safety net |

## Notes

- 2026-04-29: Plan drafted post-verification. Audit's third BLOCKER (channel haste) refuted with HIGH confidence; only #46 and #47 remain in scope. `ref:audit-haste-verify`
- 2026-04-29: AoE rule reframing means #46 is data-only; engine stays untouched. Simpler than the audit suggested. `ref:audit-aoe-research`
- 2026-04-29: Downranking formula audit found `(rank+11)/PL` was numerically close to correct `(MaxLevel+6)/PL` for many spells where MaxLevel = SpellLevel+5; errors cancelled. Worth recording so the discrepancy isn't relitigated. `ref:audit-downrank-research`
