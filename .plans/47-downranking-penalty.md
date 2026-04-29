---
status: not-started
phase: 1
updated: 2026-04-29
---

# Issue #47: TBC Downranking Spell Coefficient Level Penalty

## Goal

Implement the cMaNGOS-TBC level-penalty formula so PhDamage no longer overstates SP contribution on sub-max-rank spells (e.g., Frostbolt R3 @ L70 currently ~58% overstated).

## Context & Decisions

| Decision | Rationale | Source |
|----------|-----------|--------|
| Use cMaNGOS-TBC `MaxLevel + 6` formula (not AzerothCore/cMaNGOS-WotLK `SpellLevel + 6`) | TBC 2.5.x targets the 2.2 patch formula per Schlemiel-10753 EU forum 2026-01-14 + Blizzard 2005 blue post | issue #47 body |
| `LevelPenalty.lua` returns `1.0` when `maxLevel == nil` | Defensive fallback for incremental data backfill - engine works correctly even with partial data coverage | `.plans/engine-accuracy-blockers.md` L90 |
| Engine-first, data-last implementation order | New module + tests can land green before bulk data edits; engine is functionally inert until data has `maxLevel` (returns 1.0) | user decision, m0073 |
| Backfill `maxLevel` on all 859 per-rank entries across 9 class files | Uniformity - even physical-only entries get `maxLevel` so the data shape is consistent and physical AP scaling can be penalty-protected later if needed | user decision, m0073 |
| `maxLevel = nextRankLevel - 1` for non-top ranks; `maxLevel = level` for top rank | cMaNGOS short-circuit `spellLevel >= maxLevel` returns 1.0; setting top-rank `maxLevel == level` cleanly triggers exemption | issue #47 body |
| Apply penalty in `BuildModifiedResult` to SP bonus only, not base damage | cMaNGOS Unit.cpp: penalty multiplies SpellBonusDamage contribution, base damage unaffected | issue #47 body |
| Per-rank iteration in `Pipeline.CalculateAll` | Resolves audit note N1 (issue #49); needed so action-bar UI exercises lower ranks | issue #47 body, `.plans/engine-accuracy-blockers.md` L83 |

Recon source: orchestrator delegation at `m0072` (file:line citations for `BuildModifiedResult` SP-bonus insertion points L376/L442/L459, Pipeline structure, data shape).

## Phase 1: LevelPenalty Module + Tests [IN PROGRESS]

- [ ] **1.1 Create `Engine/LevelPenalty.lua` with `CalculateLevelPenalty(spellLevel, maxLevel, playerLevel)`** ← CURRENT
- [ ] 1.2 Implement cMaNGOS-TBC formula: top-rank exemption when `spellLevel >= maxLevel`, sub-20 multiplier `(20 - spellLevel) * 3.75`, level factor `(maxLevel + 6) / playerLevel` capped at 1.0
- [ ] 1.3 Defensive fallbacks: `maxLevel == nil` returns 1.0; `spellLevel <= 0` returns 1.0; `playerLevel <= 0` returns 1.0
- [ ] 1.4 Register on `ns.LevelPenalty` namespace and add to `PhDamage.toc` after `Engine/SpellCalc.lua`, before `Engine/ModifierCalc.lua`
- [ ] 1.5 Create `tests/test_levelpenalty.lua` with cases: top-rank exemption, sub-20 stacking (Frostbolt R3 @ L70 = 0.250), MaxLevel+6 (Greater Heal R1 = 0.729, Shadow Bolt R5 = 0.586), nil/zero defensive returns
- [ ] 1.6 Verify `busted --verbose` passes with new test count = 1184 + N (where N is number of new tests, target 8-12)
- [ ] 1.7 `luacheck .` clean

## Phase 2: Engine Integration [PENDING]

- [ ] 2.1 Modify `Engine/ModifierCalc.lua::BuildModifiedResult` standard path (L376): apply `levelPenalty = ns.LevelPenalty.CalculateLevelPenalty(rankData.level, rankData.maxLevel, playerState.level)` then `spBonus = effectiveSp * effectiveCoeff * levelPenalty`
- [ ] 2.2 Apply same penalty in hybrid path (L442 directSpBonus, L459 dotSpBonus)
- [ ] 2.3 Apply same penalty in utility path (L360 Life Tap)
- [ ] 2.4 Verify all existing tests still pass (data has no `maxLevel` yet, so penalty = 1.0 fallback - engine should be functionally unchanged)
- [ ] 2.5 Add 2-3 integration tests in `tests/test_levelpenalty.lua` (or new file) that synthesize a spell with explicit `maxLevel` and verify `BuildModifiedResult` applies the penalty correctly

## Phase 3: Per-Rank Pipeline Iteration [PENDING]

- [ ] 3.1 Modify `Engine/Pipeline.lua::CalculateAll` to iterate `for rankIdx, rankData in pairs(spellData.ranks)` and call `Pipeline.Calculate(spellID, playerState, rankIdx)` for each, storing results keyed by `spellID..":"..rankIdx`
- [ ] 3.2 Preserve existing top-rank-only behavior under a separate function or flag if needed for backwards compatibility (review existing callers first)
- [ ] 3.3 Verify tests pass; add a Pipeline-level test verifying per-rank iteration produces N results for an N-rank spell

## Phase 4: Data Backfill [PENDING]

- [ ] 4.1 Backfill `maxLevel` on all per-rank entries in `Data/SpellData_Mage.lua` (128 entries)
- [ ] 4.2 Backfill `Data/SpellData_Priest.lua` (63), `Data/SpellData_Warlock.lua` (150), `Data/SpellData_Druid.lua` (162)
- [ ] 4.3 Backfill `Data/SpellData_Shaman.lua` (80), `Data/SpellData_Paladin.lua` (60)
- [ ] 4.4 Backfill `Data/SpellData_Hunter.lua` (57), `Data/SpellData_Rogue.lua` (106), `Data/SpellData_Warrior.lua` (53)
- [ ] 4.5 Convention: for non-top ranks `maxLevel = nextRank.level - 1`; for top rank `maxLevel = level` (triggers cMaNGOS short-circuit exemption)
- [ ] 4.6 Verify each file with `luacheck` after edit; run `busted --verbose` after each class file lands to catch any data-test interactions early

## Phase 5: Validation & Acceptance Criteria [PENDING]

- [ ] 5.1 Acceptance test: Frostbolt R3 @ L70 yields effective SP coefficient ≈ 0.2035 (was ~0.814 / 0.814 * 0.250 ≈ 0.2035)
- [ ] 5.2 Acceptance test: Greater Heal R1 @ L70 yields effective coefficient ≈ 0.729 of stored
- [ ] 5.3 Acceptance test: Shadow Bolt R5 @ L70 yields ≈ 0.586 of stored
- [ ] 5.4 Acceptance test: top-rank spells (Frostbolt R11, SW:Pain R10) unchanged (penalty = 1.0)
- [ ] 5.5 Final `busted --verbose` 100% pass + `luacheck .` 0 warnings
- [ ] 5.6 Update `.plans/engine-accuracy-blockers.md` to mark Phase 2 complete
- [ ] 5.7 PR created with `Closes #47` and full Acceptance criteria checklist from issue body confirmed

## Notes

- 2026-04-29: Recon at orchestrator m0072 confirmed all 859 per-rank entries have `level` field already, none have `maxLevel`. `BuildModifiedResult` SP-bonus insertion points: ModifierCalc.lua L376 (standard), L442 (hybrid direct), L459 (hybrid dot), L360 (utility/Life Tap). `Pipeline.Calculate` already accepts optional `rankIndex` parameter.
- AzerothCore divergence (`SpellLevel + 6` vs `MaxLevel + 6`) explicitly tracked - we use `MaxLevel + 6` per cMaNGOS-TBC.
