# Changelog

## [1.3.3](https://github.com/DragonAddons/PhDamage/compare/1.3.2...1.3.3) (2026-03-15)


### Bug Fixes

* inline shared release automation ([#30](https://github.com/DragonAddons/PhDamage/issues/30)) ([4347e93](https://github.com/DragonAddons/PhDamage/commit/4347e93fb050fc788d6bd54167a8a72000be8046))

## [1.3.2](https://github.com/DragonAddons/PhDamage/compare/1.3.1...1.3.2) (2026-03-14)


### Bug Fixes

* standardize Ace3 embedded packaging paths ([#28](https://github.com/DragonAddons/PhDamage/issues/28)) ([ad3fff8](https://github.com/DragonAddons/PhDamage/commit/ad3fff83b739d062a70ff4ebfce3412bcb965917))

## [1.3.1](https://github.com/DragonAddons/PhDamage/compare/1.3.0...1.3.1) (2026-03-06)


### Bug Fixes

* stabilize local busted runs and lock Life Tap model ([#26](https://github.com/DragonAddons/PhDamage/issues/26)) ([39ce370](https://github.com/DragonAddons/PhDamage/commit/39ce370a18dabf2afadcd55db7e72a4feabe6a1f))

## [1.3.0](https://github.com/DragonAddons/PhDamage/compare/1.2.1...1.3.0) (2026-03-03)


### Features

* support spell links in /phd spell command ([#23](https://github.com/DragonAddons/PhDamage/issues/23)) ([#24](https://github.com/DragonAddons/PhDamage/issues/24)) ([7abd5d0](https://github.com/DragonAddons/PhDamage/commit/7abd5d06ddcd511331488e1b10134d55e01e83e1))

## [1.2.1](https://github.com/Xerrion/PhDamage/compare/1.2.0...1.2.1) (2026-03-01)


### Bug Fixes

* correct TalentMap indices for all classes ([#21](https://github.com/Xerrion/PhDamage/issues/21)) ([#22](https://github.com/Xerrion/PhDamage/issues/22)) ([911e925](https://github.com/Xerrion/PhDamage/commit/911e925dea976d03c31a79144faa2c613223aa98))
* name-based talent matching for TBC Anniversary index reordering ([#12](https://github.com/Xerrion/PhDamage/issues/12)) ([#19](https://github.com/Xerrion/PhDamage/issues/19)) ([34ecc84](https://github.com/Xerrion/PhDamage/commit/34ecc84e94df266390bbf71cf5f7073b1029a877))

## [1.2.0](https://github.com/Xerrion/PhDamage/compare/1.1.3...1.2.0) (2026-03-01)


### Features

* align repo setup with DragonToast ([#14](https://github.com/Xerrion/PhDamage/issues/14), [#15](https://github.com/Xerrion/PhDamage/issues/15), [#16](https://github.com/Xerrion/PhDamage/issues/16), [#17](https://github.com/Xerrion/PhDamage/issues/17)) ([#18](https://github.com/Xerrion/PhDamage/issues/18)) ([4f6b54b](https://github.com/Xerrion/PhDamage/commit/4f6b54b483d83566205cf94fcbb4cd7edf14e73a))

## [1.1.3](https://github.com/Xerrion/PhDamage/compare/1.1.2...1.1.3) (2026-02-25)


### Bug Fixes

* add contents:write permission to release workflow ([1ef3cc5](https://github.com/Xerrion/PhDamage/commit/1ef3cc535a08b8a59a402f0069b0e393a80a9dbb))

## [1.1.2](https://github.com/Xerrion/PhDamage/compare/1.1.1...1.1.2) (2026-02-25)


### Bug Fixes

* disable toc-creation for single-interface addon ([8bc1770](https://github.com/Xerrion/PhDamage/commit/8bc1770496406623da0ab27e0f4072b2a10c2a7c))

## [1.1.1](https://github.com/Xerrion/PhDamage/compare/1.1.0...1.1.1) (2026-02-25)


### Bug Fixes

* add permissions to caller workflow ([#9](https://github.com/Xerrion/PhDamage/issues/9)) ([daeb969](https://github.com/Xerrion/PhDamage/commit/daeb969f1078f702eb9c763d4338bdf00e61c128))


### Documentation

* touch up README with accurate details and consistent formatting ([#6](https://github.com/Xerrion/PhDamage/issues/6)) ([c1443ae](https://github.com/Xerrion/PhDamage/commit/c1443ae21d6cbf316b1f8bdefb7cc701ee450ef0))


### CI/CD

* add proper changelog ([ef68aaf](https://github.com/Xerrion/PhDamage/commit/ef68aaf0d7d902b7e0407b7b0725bcbbdd7c7c72))

## [1.0.0] - 2026-02-23

### 🚀 Features

- Initial commit for PhDamage Phase 1 implementation
- Phase 2 tooltip hooks and ActionBar text overlay
- Add Phase 3 test infrastructure, spells, and talents
- Add Phase 4 spell haste, new spells, and demonic tactics
- Add mage class support with 15 spells, 21 talents, and 4 auras
- Add priest class support with 7 spells, 8 talents, and 3 auras
- Add melee engine support and Warrior class
- Add Rogue class support
- Redesign tooltip for better readability
- Add label prefixes to tooltip sub-lines
- *(tooltip)* Add Scaling line showing coefficient, cast time, talent bonus
- *(tooltip)* Render PhDamage info in separate companion frame
- Add druid class support (21 spells, 19 talents, 4 auras)
- *(tooltip)* Add colored labels and split scaling into separate lines
- Add Shaman class support
- Add Paladin class support

### 🐛 Bug Fixes

- Malediction talent, redundant aura scan, and dead code
- Address code review feedback for C_UnitAuras and DoT DPS
- Add missing PrintSpellDot function and create PrintSpellDirect
- Logic and data bugs from Phase 1 review
- *(tooltip)* Rank selection and ActionBar ElvUI compatibility
- Phase 1 critical bugs
- Phase 2 high severity bugs
- *(engine)* Missing hit multiplier on hybrid and periodic components
- *(engine)* Fix CritCalc.lua syntax error from corrupted edit
- Phase 5 hunter class + code review (16 bug fixes)
- Resolve critical engine bugs and improve code quality
- *(tooltip)* Anchor companion frame below GameTooltip instead of beside
- *(tooltip)* Fix ElvUI SetTemplate call — use mixin method with pcall guard

### 🚜 Refactor

- Phase 4 code cleanup and design fixes

### 📚 Documentation

- Add README with badges and MIT license
- Polish README with flat-square badges and structured tables

### ⚡ Performance

- Phase 3 performance optimizations

### ⚙️ Miscellaneous Tasks

- Add Ace3 submodule for local LSP resolution
- Clean up luacheckrc configuration
- Fix release workflow
