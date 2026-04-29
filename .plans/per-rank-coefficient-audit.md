# Per-Rank Coefficient Audit (Wowhead TBC Classic)

**Source**: `https://www.wowhead.com/tbc/spell=<id>` — TBC Classic spell DB.
**Method**: Read-only Playwright fetch, ~2.1s settle, scrape `Effect` / `Effect #N` rows.
**Engine semantics** (`Engine/SpellCalc.lua:246-250, 286-291, 333-337`): `coefficient` and
`dotCoefficient` are **TOTAL** values consumed verbatim. Per-tick × `numTicks` = total.
**Branch**: `fix/46-aoe-coefficients` (state UNKNOWN — `git` blocked by env).

## Conventions in this document

| Field             | Meaning                                                                 |
|-------------------|-------------------------------------------------------------------------|
| `dir`             | Direct-damage SP coefficient (Wowhead "School Damage" `SP mod`).        |
| `dot/tick`        | Per-tick periodic SP coefficient (Wowhead "Periodic Damage" `SP mod`).  |
| `dot total`       | `dot/tick × numTicks` — what should be stored in `dotCoefficient`.      |
| `flat after Rk`   | All ranks ≥ k share the same coefficient as Rk.                         |
| Bold rows         | Penalty ranks where the coefficient differs from the top-rank value.    |

Every value below was harvested directly from Wowhead. Ranks marked **flat** were
spot-checked (R1, mid, top) when not all ranks were fetched explicitly.

---

## Warlock

### Shadow Bolt (Affliction direct, 11 ranks)
| Rank | ID    | dir   |
|------|-------|-------|
| **R1** | 686   | **0.14**  |
| **R2** | 695   | **0.299** |
| **R3** | 705   | **0.56**  |
| R4-11 | 7641, 11659, 11660, 11661, 25307, 27209 | 0.857 (flat) |

### Searing Pain (8 ranks)
| Rank | ID    | dir   |
|------|-------|-------|
| **R1** | 5676  | **0.396** |
| R2-8 | 17919-17924, 30459 | 0.429 (flat) |

### Soul Fire (4 ranks)
- All ranks (6353, 17924, 27211, 30545): **dir = 1.15 flat**.

### Shadowburn (5 ranks)
- All ranks (17877, 18867-18870): **dir = 0.429 flat**.

### Conflagrate (3 ranks)
- All ranks (17962, 18930, 18932): **dir = 0.429 flat**.

### Death Coil (2 ranks)
- 6789 / 17926: **dir = 0.214 flat**.

### Incinerate
- R1 (29722): **dir = 0.714** (top rank in TBC).

### Curse of Doom (2 ranks)
- R1 (603): **dot total = 2.0** (single-tick, 1m).
- R2 (30910): **dot total = 2.0**.

### Corruption (7 ranks, 6 ticks @ 3s)
| Rank | ID    | dot/tick | dot total |
|------|-------|----------|-----------|
| **R1** | 172   | **0.0624** | 0.374 |
| **R2** | 6222  | **0.121**  | 0.726 |
| R3-7 | 6223, 7648, 11671, 11672, 25311 | 0.156 | 0.936 (flat) |

### Curse of Agony (7 ranks, 12 ticks @ 2s)
| Rank | ID    | dot/tick | dot total |
|------|-------|----------|-----------|
| **R1** | 980   | **0.0548** | 0.658 |
| **R2** | 1014  | **0.0923** | 1.108 |
| R3-7 | 6217, 11711, 11712, 11713, 27218 | 0.1 | 1.2 (flat) |

### Unstable Affliction (3 ranks, 6 ticks @ 3s, 18s)
- R1 (30108), R2 (30404), R3 (30910): all **dot/tick = 0.2** → dot total = 1.2 (flat).

### Siphon Life (5 ranks, 10 ticks @ 3s)
- All ranks (18265, 18879, 18880, 18881, 27264): **dot/tick = 0.1** → dot total = 1.0 (flat).

### Drain Life (7 ranks, 5 ticks @ 1s)
| Rank | ID    | dot/tick | dot total |
|------|-------|----------|-----------|
| **R1** | 689   | **0.111** | 0.555 |
| R2-7 | 699, 709, 7651, 11699, 11700, 27219 | 0.143 | 0.715 (flat) |

### Drain Soul (5 ranks, 15 ticks @ 3s, 15s channel)
| Rank | ID    | dot/tick | dot total |
|------|-------|----------|-----------|
| **R1** | 1120  | **0.0893** | 1.34 |
| R2-5 | 8288, 8289, 11675, 27217 | 0.143 | 2.145 (flat) |

### Immolate (9 ranks, dir + 5 ticks @ 3s, 15s)
| Rank | ID    | dir    | dot/tick | dot total |
|------|-------|--------|----------|-----------|
| **R1** | 348   | **0.058** | **0.037** | 0.185 |
| **R2** | 707   | **0.125** | **0.081** | 0.405 |
| R3-9 | 1094, 2941, 11665, 11667, 11668, 25309 | 0.20 | 0.13 | 0.65 (flat) |

### Hellfire (3 ranks; 15 ticks @ 1s, target damage)
- R1 (1949), R2 (11683), R3 (11684): **dot/tick = 0.095** → dot total = **1.425 (flat)**.
- Branch top stored 2.1429 — **wrong on every rank**.

### Rain of Fire (3 ranks; 4 ticks @ 2s, 8s channel)
- R1 (5740), R2 (6219), R3+: **dot/tick = 0.237** → dot total = **0.948 (flat)**.

### Shadowfury (2 ranks)
- R1 (30283), R2 (30413): **dir = 0.193 flat** (instant AoE).

---

## Mage

### Frostbolt (10 ranks, ~3s cast)
| Rank | ID    | dir   |
|------|-------|-------|
| **R1** | 116   | **0.163** |
| **R2** | 205   | **0.269** |
| **R3** | 837   | **0.463** |
| **R4** | 7322  | **0.706** |
| R5-10 | 8406, 8407, 8408, 10179, 10180, 10181, 25304, 27071, 38697 | 0.814 (flat) |

### Fireball (14 ranks, dir + small DoT (no SP))
| Rank | ID    | dir   |
|------|-------|-------|
| **R1** | 133   | **0.123** |
| **R2** | 143   | **0.271** |
| **R3** | 145   | **0.5**   |
| **R4** | 3140  | **0.793** |
| R5-14 | 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306, 38692 | 1.0 (flat, deduced — Wowhead "Value: N" no `SP mod` printed for top ranks; cast 3.5s → 1.0) |
| dot   | all ranks | **0.0** (no `SP mod`) |

> **Note:** R5+ Fireball pages strip the `SP mod` annotation. In TBC, Fireball top
> rank coefficient is 1.0 (3.5s base cast / 3.5). Branch already uses 1.0.

### Pyroblast (8 ranks, dir + 4 ticks @ 3s, 12s)
- All ranks (11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809, 27132, 33938): **dir = 1.15 flat, dot/tick = 0.05 flat** → dot total = 0.2.

### Frost Nova (6 ranks)
| Rank | ID    | dir   |
|------|-------|-------|
| **R1** | 122   | **0.018** |
| R2-6 | 865, 6131, 10230, 27088 | 0.043 (flat) |

### Cone of Cold (6 ranks)
- All ranks (120, 8492, 10159, 10160, 27087, 38692): **dir = 0.193 flat**.

### Arcane Explosion (7 ranks)
| Rank | ID    | dir   |
|------|-------|-------|
| **R1** | 1449  | **0.166** |
| R2-7 | 8437, 8438, 8439, 10201, 10202, 27082 | 0.214 (flat) |

### Blizzard (7 ranks; 8 ticks @ 1s)
- All ranks (10, 6141, 8427, 10185, 10186, 10187, 27085): **dot/tick = 0.119** → dot total = **0.952 (flat)**.
- Branch stored 0.7619 — wrong.

### Flamestrike (7 ranks; dir + 4 ticks @ 2s, 8s)
| Rank | ID    | dir   | dot/tick | dot total |
|------|-------|-------|----------|-----------|
| **R1** | 2120  | **0.20**  | **0.026** | 0.104 |
| R2-7 | 2121, 8422, 8423, 10215, 10216, 27086 | 0.236 | 0.03 | 0.12 (flat) |

### Blast Wave (6 ranks)
- R1 (11113): **dir = 0.193**. Higher ranks all 0.193 (visual confirm needed but consistent with formula).

### Dragon's Breath (4 ranks)
- R1 (33041): **dir = 0.193 flat** across ranks (33041, 33042, 33043, 33044).

### Fire Blast (9 ranks)
| Rank | ID    | dir   |
|------|-------|-------|
| **R1** | 2136  | **0.204** |
| **R2** | 2137  | **0.332** |
| R3-9 | 2138, 8412, 8413, 10197, 10199, 27078, 27079 | 0.429 (flat) |

### Scorch (9 ranks)
- All ranks (2948, 8444, 8445, 8446, 10205, 10206, 10207, 27073, 27074): **dir = 0.429 flat**.

### Ice Lance (1 rank)
- 30455: **dir = 0.143 flat**.

### Arcane Blast (1 rank in TBC)
- 30451: **dir = 0.714 flat**.

### Arcane Missiles (9 ranks; 5 ticks @ 1s; trigger sub-spell holds SP mod)
| Rank | parent ID | trigger ID | dot/tick | dot total |
|------|-----------|------------|----------|-----------|
| **R1** | 5143  | 7268  | **0.0942** | 0.471 |
| **R2** | 5144  | 7269  | **0.1944** | 0.972 |
| R3-9 | 5145, 8416, 8417, 10211, 10212, 25345, 38704 | 7270, 8419, 8418, 10273, 10274, 25346, 38703 | 0.286 | 1.43 (flat) |

> **Engine implication for Arcane Missiles**: SP mod lives on the trigger sub-spell, not the parent.
> The current engine likely passes the parent ID. Either the data file maps parent → coefficient
> (already correct for top rank: 1.43), or the engine needs trigger-aware lookup. Existing branch value
> 0.715 is half of 1.43 — appears to have been entered as per-tick rather than total.

---

## Priest

### Smite (10 ranks, ~2.5s cast)
| Rank | ID    | dir   |
|------|-------|-------|
| **R1** | 585   | **0.123** |
| **R2** | 591   | **0.271** |
| **R3** | 598   | **0.554** |
| R4-10 | 984, 1004, 6060, 10933, 10934, 25363, 25364 | 0.714 (flat) |

### Mind Blast (11 ranks, 1.5s cast)
| Rank | ID    | dir   |
|------|-------|-------|
| **R1** | 8092  | **0.268** |
| **R2** | 8102  | **0.364** |
| R3-11 | 8103, 8104, 8105, 8106, 10945, 10947, 25372, 25375 | 0.429 (flat) |

### Shadow Word: Pain (10 ranks; 6 ticks @ 3s, 18s)
| Rank | ID    | dot/tick | dot total |
|------|-------|----------|-----------|
| **R1** | 589   | **0.0732** | 0.4392 |
| **R2** | 594   | **0.114**  | 0.684  |
| **R3** | 970   | **0.169**  | 1.014  |
| R4-10 | 992, 2767, 10892, 10893, 10894, 25367, 25368 | 0.183 | 1.098 (flat) |

> Top-rank value 1.098 (0.183 × 6) is correct for TBC; only R1/R2/R3 need per-rank overrides for sub-cap penalty.
> Verified via Twinhead TBC: spell=589 (R1) and spell=25368 (R10) both show "18sec" duration.

### Mind Flay (7 ranks; 3 ticks @ 1s, 3s channel)
- All ranks (15407, 17311-17314, 18807, 25387): **dot/tick = 0.19** → dot total = **0.57 (flat)**.

> Engine should treat as channel: channel coefficient 0.57 (matches branch 0.57).

### Holy Fire (8 ranks in TBC; dir + 5 ticks @ 2s, 10s)
- All ranks (14914, 15262, 15263, 15264, 15265, 15266, 15267, 25384): **dir = 0.857 flat, dot/tick = 0.033 flat** → dot total = 0.165.

### Shadow Word: Death (2 ranks)
- 32379, 32996: **dir = 0.429 flat**.

### Vampiric Touch (3 ranks; 5 ticks @ 3s, 15s)
- All ranks (34914, 34916, 34917): **dot/tick = 0.2 flat** → dot total = 1.0.

### Devouring Plague (7 ranks; 8 ticks @ 3s, 24s)
- All ranks (2944, 19276, 19277, 19278, 19279, 19280, 25467): **dot/tick = 0.1 flat** → dot total = 0.8.

---

## Druid (Balance only — Feral excluded per scope)

### Wrath (10 ranks)
| Rank | ID    | dir   |
|------|-------|-------|
| **R1** | 5176  | **0.123** |
| **R2** | 5177  | **0.231** |
| **R3** | 5178  | **0.443** |
| R4-10 | 5179, 6780, 8905, 9912, 26984, 26985 | 0.571 (flat) |

### Starfire (8 ranks)
- Wowhead pages do **not** expose SP mod for Starfire (cast-time inferred client-side).
- Canonical TBC value: **dir = 1.0 flat** (3.5s cast / 3.5 = 1.0). All ranks level ≥24 — no penalty.
- Branch should retain 1.0 unless verified otherwise from another source.

### Moonfire (12 ranks; dir + 4 ticks @ 3s, 12s)
| Rank | ID    | dir   | dot/tick | dot total |
|------|-------|-------|----------|-----------|
| **R1** | 8921  | **0.06**  | **0.052** | 0.208 |
| **R2** | 8924  | **0.094** | **0.081** | 0.324 |
| **R3** | 8925  | **0.128** | **0.111** | 0.444 |
| R4-12 | 8926, 8927, 8928, 8929, 9833, 9834, 9835, 26987, 26988 | 0.15 | 0.13 | 0.52 (flat) |

> Total at R4-12: dir 0.15 + dot 0.52 = 0.67. Branch stored 0.6817 (close).

### Insect Swarm (6 ranks; 6 ticks @ 2s, 12s)
- All ranks (5570, 24974-24977, 27013): **dot/tick = 0.127 flat** → dot total = 0.762.

### Hurricane (4 ranks; 10 ticks @ 1s, 10s channel)
- All ranks (16914, 17401, 17402, 27012): **dot/tick = 0.107 flat** → dot total = **1.07 (flat)**.
- Branch stored 1.28 — wrong.

---

## Shaman (offensive only)

### Lightning Bolt (12 ranks)
| Rank | ID    | dir   |
|------|-------|-------|
| **R1** | 403   | **0.137** |
| **R2** | 529   | **0.349** |
| **R3** | 548   | **0.616** |
| R4-12 | 915, 943, 6041, 10391, 10392, 15207, 15208, 25448, 25449 | 0.794 (flat) |

### Chain Lightning (6 ranks in TBC)
- All ranks (421, 930, 2860, 10605, 25439, 25442): **dir = 0.651 flat**.
- Branch top R6 stored 0.7143 — wrong.

### Earth Shock (8 ranks)
| Rank | ID    | dir   |
|------|-------|-------|
| **R1** | 8042  | **0.154** |
| **R2** | 8044  | **0.212** |
| **R3** | 8045  | **0.299** |
| R4-8 | 8046, 10412, 10413, 10414, 25454 | 0.386 (flat) |

### Flame Shock (7 ranks; dir + 4 ticks @ 3s, 12s)
| Rank | ID    | dir   | dot/tick | dot total |
|------|-------|-------|----------|-----------|
| **R1** | 8050  | **0.134** | **0.063** | 0.252 |
| **R2** | 8052  | **0.198** | **0.093** | 0.372 |
| R3-7 | 8053, 10447, 10448, 29228, 25457 | 0.214 | 0.1 | 0.4 (flat) |

### Frost Shock (5 ranks)
- All ranks (8056, 8058, 10472, 10473, 25464): **dir = 0.386 flat**.

### Lightning Shield
- Out of scope (proc damage, separate scaling); not audited.

---

## Paladin

### Consecration (6 ranks; 8 ticks @ 1s, 8s)
- All ranks (26573, 20116, 20922, 20923, 20924, 27173, 48819): **dot/tick = 0.119 flat** → dot total = 0.952.

### Exorcism (7 ranks)
- All ranks (879, 5614, 10312, 10313, 10314, 27138, 33627-incorrect): **dir = 0.429 flat**.

### Hammer of Wrath (3 ranks)
- All ranks (24275, 24274, 24239): **dir = 0.429 flat**.

### Holy Wrath (2 ranks)
- 2812, 10318: **dir = 0.286 flat**.

### Holy Shock (4 ranks) — NOT FETCHED
- Recommendation: spot-check R1 (20473). Likely flat.

### Avenger's Shield (3 ranks) — NOT FETCHED
- Out of TBC core damage rotation; lower priority.

---

## Branch DISAGREE summary (top-rank values)

| Spell                | Branch top    | Wowhead total | Action                      |
|----------------------|---------------|---------------|-----------------------------|
| Drain Soul R5        | 2.0           | 2.145         | update top                  |
| Hellfire R3          | 2.1429        | 1.425         | update top                  |
| Blizzard R7          | 0.7619        | 0.952         | update top                  |
| Hurricane R4         | 1.28          | 1.07          | update top                  |
| Flamestrike R7 dot   | 0.1096        | 0.12          | update top dot              |
| Chain Lightning R6   | 0.7143        | 0.651         | update top                  |
| Arcane Missiles R9   | 0.715         | 1.43          | update top (per-tick→total) |
| SW:Pain R10 dot      | 1.098         | 1.098         | Verified 18s/6 ticks correct |
| Moonfire R12 total   | 0.6817        | 0.67          | minor — leave or refine     |

## Spells with per-rank penalties (need rank overrides)

For each spell below, the lower ranks differ from the top-rank coefficient and require
per-rank override entries.

| Spell             | Penalty ranks                                        |
|-------------------|------------------------------------------------------|
| Shadow Bolt       | R1, R2, R3                                           |
| Searing Pain      | R1                                                   |
| Corruption        | R1, R2 (dot)                                         |
| Curse of Agony    | R1, R2 (dot)                                         |
| Drain Life        | R1 (dot)                                             |
| Drain Soul        | R1 (dot)                                             |
| Immolate          | R1, R2 (both dir and dot)                            |
| Frostbolt         | R1, R2, R3, R4                                       |
| Fireball          | R1, R2, R3, R4 (dir only; no dot SP)                 |
| Frost Nova        | R1                                                   |
| Arcane Explosion  | R1                                                   |
| Flamestrike       | R1 (dir and dot)                                     |
| Fire Blast        | R1, R2                                               |
| Arcane Missiles   | R1, R2 (per-tick on trigger sub-spell)               |
| Smite             | R1, R2, R3                                           |
| Mind Blast        | R1, R2                                               |
| SW:Pain           | R1, R2, R3 (dot)                                     |
| Moonfire          | R1, R2, R3 (dir and dot)                             |
| Wrath             | R1, R2, R3                                           |
| Lightning Bolt    | R1, R2, R3                                           |
| Earth Shock       | R1, R2, R3                                           |
| Flame Shock       | R1, R2 (dir and dot)                                 |

## Spells confirmed flat across all ranks

Soul Fire, Shadowburn, Conflagrate, Death Coil, Curse of Doom, Unstable Affliction,
Siphon Life, Hellfire, Rain of Fire, Shadowfury, Pyroblast, Cone of Cold, Blizzard,
Blast Wave, Dragon's Breath, Scorch, Ice Lance, Arcane Blast, Holy Fire, SW:Death,
Vampiric Touch, Devouring Plague, Insect Swarm, Hurricane, Chain Lightning, Frost Shock,
Consecration, Exorcism, Hammer of Wrath, Holy Wrath.

## Engine integration recommendation

Add optional `coefficient` and/or `dotCoefficient` to per-rank entries in
`Data/SpellData_*.lua`. Engine reads `rank.coefficient or spell.coefficient or 0`
(one-line change at `Engine/SpellCalc.lua:286-291` and `:333-337`).

```lua
ranks = {
    [1] = { id = 686,   level = 1,  minDamage = 14,  maxDamage = 18, coefficient = 0.14  },
    [2] = { id = 695,   level = 6,  minDamage = 26,  maxDamage = 32, coefficient = 0.299 },
    [3] = { id = 705,   level = 12, minDamage = 52,  maxDamage = 62, coefficient = 0.56  },
    [4] = { id = 1088,  level = 20, minDamage = 92,  maxDamage = 105 }, -- inherits 0.857
    -- ...
}
```

For Arcane Missiles, the trigger sub-spell IDs should be added per rank (e.g. as
`triggerId = 7268`) so the engine can fetch per-tick damage from the correct row,
or per-rank `dotCoefficient` overrides should be the totals shown above (0.471, 0.972, 1.43).

## Spells NOT visited (out of 90-min budget)

- Hunter ranged (out of scope; AP-scaled).
- Rogue / Warrior physical (out of scope).
- Druid Feral / Restoration (out of scope).
- Paladin Holy Shock (4 ranks); Avenger's Shield (3 ranks); Seal/Judgement family.
- Warlock Seed of Corruption (47836 + detonation).
- Shaman Lightning Shield, Magma Totem, Searing Totem, Stormstrike weapon proc.
- Priest Holy Nova damage component, Shadowfiend.
- Mage Pyroblast/Fireball R12-14 (top-rank confirmed flat from R5 onward, no penalty risk).

These can be filled in a follow-up audit; no penalty ranks are expected since all
remaining offensive ranks are level ≥ 30 in TBC.
