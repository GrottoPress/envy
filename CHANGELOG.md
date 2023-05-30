# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased] - 

### Fixed
- Fix wrong shard version in `shard.yml`

## [1.0.1] - 2023-05-30

### Fixed
- Rescue env file permissions change errors

## [1.0.0] - 2023-05-30

### Added
- First stable release

## [0.4.0] - 2022-12-16

### Added
- Add support for hashes nested under lists

## [0.3.1] - 2022-03-17

### Added
- Ensure support for *Crystal* v1.1, v1.2 and v1.3

## [0.3.0] - 2021-04-07

### Changed
- Bump minimum required *Crystal* version to v1.0
- Replace travis-ci with GitHub actions

## [0.2.1] - 2020-03-21

### Changed
- Refactor to remove `Envy::DEFAULT_FILE_PERM` constant

### Fixed
- Set permissions for all files that exist (not just readable ones).

## [0.2.0] - 2020-03-09

### Added
- Add support for Crystal version 0.33.0

### Changed
- Set permissions for all config files (not just the selected one)

## [0.1.0] - 2020-01-21

### Added
- Initial public release
