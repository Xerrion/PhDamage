---
status: in-progress
phase: 5
updated: 2026-04-29
---

### Goal

Fix all four root causes of expected-damage inaccuracy in PhDamage (crit double-count, stack-aware aura modifiers, channel-spell dual-ID resolution) and ship the /phd debug diagnostic that surfaced the channel bug.

### Context & Decisions

| Decision | Rationale | Source |
|----------|-----------|--------|
| Audit 35 candidate talent/aura entries for crit double-count | Initial report suggested a widespread issue where PhDamage adds +crit and +crit-damage both to the same entry incorrectly. | ref:ses_2274fc5b8ffe4UiHDpeeY7ue1E |
| Option A for test updates: Recompute combined-build crit math | Changing the engine to remove double-counting invalidates many test fixtures. Choice: re-calculate the expected damage totals for the new engine behavior rather than trying to preserve old totals with fake data. | ref:ses_2274fc5b8ffe4UiHDpeeY7ue1E |
| Extract stack-scaling logic to Core/StateCollector and Engine/ModifierCalc | Enables auras to scale their damage bonus by their current stack count (e.g. Shadow Weaving, Winter's Chill, Healing Way). | ref:ses_227058e87ffeOTv2G5XvjxoCYl |
| Implement /phd debug [slot] diagnostic | Provides raw action info, spell ID resolution, and internal state for a specific action bar slot. Essential for surfacing data bugs in the field. | ref:user m0037 |
| Single umbrella PR for Bugs A-C + Diagnostic | The changes are conceptually linked as "Accuracy and Diagnostic" and share test bootstrap context. | ref:user m0039 |
| Fetch Sanctified Seals behavior from Wowpedia | Agent research on TBC-era behavior for talent ID 20227 (Sanctified Seals) confirmed it is a flat crit increase, not a double-count. | ref:ses_2274201d0ffe0wZpXcCAWqLMIh |
| Add optional effectID field to rank entries (additive schema) | Survey confirms zero existing readers of effectID field name; change is backwards-compatible. | ref:ses_227058e87ffeOTv2G5XvjxoCYl |
| Consolidate 3 duplicated BuildSpellID* builders into a single ns.SpellResolver module | DRY. Currently the same loop is implemented in Presentation/ActionBar.lua, Presentation/Tooltip.lua, and Presentation/Diagnostics.lua with slightly different output shapes. Extract makes the effectID branch live in one place and become unit-testable. | ref:ses_227058e87ffeOTv2G5XvjxoCYl |
| Engine and Pipeline are untouched | Survey confirmed zero combat-log listeners in PhDamage and engine looks up by base ID only. Schema change only touches Data/ + Presentation/ (resolver) + new tests. | ref:ses_227058e87ffeOTv2G5XvjxoCYl |
| Hellfire R4 fix: change spellID = 27214 to spellID = 27213, effectID = 27214 | Restores internal consistency (R1-3 already use channel IDs); makes both IDs resolve to base 1949 via the new resolver. | ref:ses_2270ab4a7ffejSRG0ZDytJYHrf |
| Cross-class channel audit scope: Rain of Fire R5 + Blizzard, Volley, Hurricane | All use Aura #23 Periodic Trigger Spell. Rank IDs in current data files look suspicious (RoF R5 27212 in particular). In-game verification required before assuming dual-ID; in-PR scope = update those entries that we can verify via Twinhead/Wowhead and add test fixtures. Items we cannot verify in this PR get explicit follow-up issues. | ref:ses_2270ab4a7ffejSRG0ZDytJYHrf |
| Drain Life, Drain Soul, Mind Flay, Arcane Missiles, Tranquility, Health Funnel: NOT in scope | These use different mechanics (Periodic Drain or Trigger Missile, not Periodic Trigger Spell). Survey + agent research suggest cast and effect share an ID. Out of scope unless explicitly identified during the cross-class audit. | ref:ses_2270ab4a7ffejSRG0ZDytJYHrf |
| Hellfire R1 level: not corrected in this PR | Twinhead says level 30, current data says level 12. Different bug, deferred to follow-up issue. Plan-creep prevention. | ref:ses_2270ab4a7ffejSRG0ZDytJYHrf |
| Block PR #45, expand scope to include Phase 5 | User instruction (m0042). Same branch, additional commits, updated PR body. | User answer (m0042) |

### Phases

**Phase 1: Bug A - Crit double-count [COMPLETE]**
- [x] 1.1 Audit all 35 candidate entries with wow-addon agent
- [x] 1.2 Resolve Sanctified Seals INCONCLUSIVE via Wowpedia fetch
- [x] 1.3 Apply 17 full + 2 partial REMOVE deletes across 8 TalentMap files
- [x] 1.4 Update 11 dependent test files (Option A: recompute combined-build crit math)
- [x] 1.5 Add tests/test_crit_double_count.lua regression
- [x] 1.6 Reviewer pass APPROVE

**Phase 2: Bug B - Stack-aware aura modifiers [COMPLETE]**
- [x] 2.1 Modify Core/StateCollector.lua, Engine/ModifierCalc.lua for stackFactor
- [x] 2.2 Update AuraMap_Warlock/Mage/Priest/Shaman with maxStacks fields
- [x] 2.3 Bonus fix: Healing Way bug (29203) corrected from 0.06 flat to 0.18 maxStacks=3
- [x] 2.4 New tests/test_stack_scaling.lua (22 cases)
- [x] 2.5 Update 4 existing test files for stack-aware contract
- [x] 2.6 Reviewer pass APPROVE

**Phase 3: Bug C - /phd debug diagnostic [COMPLETE]**
- [x] 3.1 Implement Diagnostics.PrintDebug + helpers in Presentation/Diagnostics.lua
- [x] 3.2 Wire slash dispatch in Core/Init.lua
- [x] 3.3 Reviewer pass APPROVE

**Phase 4: Polish [COMPLETE]**
- [x] 4.1 Tighten partial-keep test (Phase 1 NOTE 3)
- [x] 4.2 Delete stale Fire Vulnerability TODO (Phase 2 INFO 1)
- [x] 4.3 Reword ApplyAuraEntry doc-comment (Phase 2 INFO 2)
- [x] 4.4 Add countField clarifying comment (Phase 2 LOW)
- [x] 4.5 Replace Unicode arrow + refresh Diagnostics file header (Phase 3 INFO 1+2)
- [x] 4.6 Reviewer pass APPROVE
- [x] 4.7 Commit (3 commits) + push + open PR #45

**Phase 5: Bug D - Channel-spell dual-ID resolution [IN PROGRESS]**
- [x] 5.1 Diagnose via /phd debug output: slot 6 returns spellID 27213, no resolution.
- [x] 5.2 Identify 27213 = Hellfire R4 channel-cast, effect ID 27214.
- [x] 5.3 Survey resolver/listener code paths.
- [ ] 5.4 Design + implement ns.SpellResolver module ← CURRENT
- [ ] 5.5 Refactor Presentation/ActionBar.lua:35-47 to use ns.SpellResolver.Resolve instead of file-local BuildSpellIDMap.
- [ ] 5.6 Refactor Presentation/Tooltip.lua:133-141 to use ns.SpellResolver.Resolve.
- [ ] 5.7 Refactor Presentation/Diagnostics.lua:640-653 to use ns.SpellResolver.Resolve.
- [ ] 5.8 Fix Hellfire R4 in Data/SpellData_Warlock.lua:445: change [4] = { spellID = 27214, ... } to [4] = { spellID = 27213, effectID = 27214, ... }. Add effectID for ranks 1-3 too.
- [ ] 5.9 Cross-class channel audit (verify against Twinhead/Wowhead via wow-addon agent): Rain of Fire, Blizzard, Volley, Hurricane.
- [ ] 5.10 Add tests/test_spell_resolver.lua with confirmed channel fixtures.
- [ ] 5.11 Verify with bootstrap, luacheck, and stack-scaling regression.
- [ ] 5.12 Reviewer pass on Phase 5 changes.
- [ ] 5.13 Update PR #45 body to document Bug D + the resolver consolidation.
- [ ] 5.14 Commit (1-2 commits) and push to existing branch.
- [ ] 5.15 Wait for CI; address any CodeRabbit findings before owner squash-merge.

### Notes

- 2026-04-29: Phases 1-4 complete. Crit double-counting fixed, stack scaling implemented, and diagnostic command shipped in PR #45.
- 2026-04-29: User ran /phd debug 6, surfaced spellID 27213 with no resolution. Architectural bug. ref:user observation m0039
- 2026-04-29: wow-addon agent confirmed 27213 = Hellfire R4 channel-cast; effect ID is 27214. Pattern is class-wide for Aura #23 spells. ref:ses_2270ab4a7ffejSRG0ZDytJYHrf
- 2026-04-29: Survey confirmed PhDamage has zero combat-log listeners; Engine untouched; only 3 reverse-map builders need fixing. Decision: consolidate into ns.SpellResolver. ref:ses_227058e87ffeOTv2G5XvjxoCYl
- 2026-04-29: User chose "Block #45, do full architectural fix now" (m0042). PR will be expanded with additional commits on the same branch.
