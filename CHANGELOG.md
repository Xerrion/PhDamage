# Changelog

## [1.1.0](https://github.com/Xerrion/PhDamage/compare/1.0.0...1.1.0) (2026-02-23)


### Features

* add druid class support (21 spells, 19 talents, 4 auras) ([d2d1fda](https://github.com/Xerrion/PhDamage/commit/d2d1fdadbc41236e6617a0edffffe2d3d1328e18))
* add label prefixes to tooltip sub-lines ([0434295](https://github.com/Xerrion/PhDamage/commit/0434295c0a89c1b4eeb0fea3259d9770c9227a56))
* add mage class support with 15 spells, 21 talents, and 4 auras ([38dc897](https://github.com/Xerrion/PhDamage/commit/38dc897c3b2d0a895187bc1462f2682b94882bae))
* add melee engine support and Warrior class ([4b1920a](https://github.com/Xerrion/PhDamage/commit/4b1920ac025fd0ab7da07d8eb0f4afaaafc00bfe))
* add Paladin class support ([997f8c6](https://github.com/Xerrion/PhDamage/commit/997f8c65a9fc720f3218613573bdf958667eaa90))
* add priest class support with 7 spells, 8 talents, and 3 auras ([c10426d](https://github.com/Xerrion/PhDamage/commit/c10426dfa76d56cb66ecf3a65bf00f5f49f1bf51))
* add Rogue class support ([bfda74c](https://github.com/Xerrion/PhDamage/commit/bfda74c8a373c2d9f8b08133454f31f13c205651))
* add Shaman class support ([44062d1](https://github.com/Xerrion/PhDamage/commit/44062d18d9c8f5696cf6097b97e7c0e5b8928146))
* redesign tooltip for better readability ([ca9a0f7](https://github.com/Xerrion/PhDamage/commit/ca9a0f7b0b23de35a8c3ec81d446e1c7ea9090f0))
* **tooltip:** add colored labels and split scaling into separate lines ([51478b5](https://github.com/Xerrion/PhDamage/commit/51478b5fcda9b57994c999b46be209c625d07844))
* **tooltip:** add Scaling line showing coefficient, cast time, talent bonus ([218c4a7](https://github.com/Xerrion/PhDamage/commit/218c4a754a7e559b0aa9669193d1ce412e2f1d7c))
* **tooltip:** render PhDamage info in separate companion frame ([334eea5](https://github.com/Xerrion/PhDamage/commit/334eea52976e3e391cc55f8dd17c6a7fc2c8813d))


### Bug Fixes

* phase 5 hunter class + code review (16 bug fixes) ([a71a63d](https://github.com/Xerrion/PhDamage/commit/a71a63d882d006fc0415c40fbd852ba38020e417))
* resolve critical engine bugs and improve code quality ([1fb74ac](https://github.com/Xerrion/PhDamage/commit/1fb74acfbbd44ccb157cb9097350fac8bc5d612f))
* **tooltip:** anchor companion frame below GameTooltip instead of beside ([a45931a](https://github.com/Xerrion/PhDamage/commit/a45931a17b62af8db61a8a5491ba5dec1da099ab))
* **tooltip:** fix ElvUI SetTemplate call — use mixin method with pcall guard ([56b08ef](https://github.com/Xerrion/PhDamage/commit/56b08ef6b16f91a15de77e0da1d3f6fee1681847))


### Documentation

* add README with badges and MIT license ([52c8d84](https://github.com/Xerrion/PhDamage/commit/52c8d8487a81f3671d6a277d8ab766b547891fc3))
* polish README with flat-square badges and structured tables ([7380094](https://github.com/Xerrion/PhDamage/commit/73800944a7c8b7d501a3b97508c0b39a27a264e7))


### CI/CD

* fix release workflow ([3438d41](https://github.com/Xerrion/PhDamage/commit/3438d41a3ee10efb15ff32e80d912fbd639fe627))
* migrate from git-cliff to release-please ([#1](https://github.com/Xerrion/PhDamage/issues/1)) ([57ed729](https://github.com/Xerrion/PhDamage/commit/57ed729bb61d8d4c5df28c3a802d606b7080f852))

## [unreleased]

### 💼 Other

- Fix missing hit multiplier on hybrid and periodic components
- Fix CritCalc.lua syntax error from corrupted edit
