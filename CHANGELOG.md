# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Now the bundle with Gosu-MRuby-Wrapper uses the fused way of loading.

## [1.1.3] - 2023-11-18

### Added

- Animation for when the player is moving.

### Changed

- Now the player ship properly blinks when invulnerable.

## [1.1.2] - 2023-11-02

Another quick patch to fix a really small bug, I'm a dummy sorry.

### Fixed

- Destroying small asteroids (the really small ones) doesn't give any score at all.

## [1.1.1] - 2023-11-02

Quick patch to fix a little something.

### Fixed

- Score was saved regardless of whether it was a highscore or not.

## [1.1.0] - 2023-11-01

### Added

- Sound effects (both in-game and for the menu).
- Display game version on menu screen.
- Collisions with asteroids now both destroys them and gives score.
- Highscore is now recorded and saved.

## [1.0.0] Jam - 2023-10-22

This is the version presented for the [Gosu Game Jam 5](https://itch.io/jam/gosu-game-jam-5).

[unreleased]: https://github.com/chadowo/asteritos/compare/v1.1.0...HEAD
[1.1.3]: https://github.com/chadowo/asteritos/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/chadowo/asteritos/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/chadowo/asteritos/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/chadowo/asteritos/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Chadowo/asteritos/releases/tag/v1.0.0
