# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [0.4.0] - 2016-08-04

### Features

- Added support for Capybara Poltergeist driver

## [0.3.1] - 2016-07-29

### Fixes

- Make sure we're setting a `user.email` for git so it doesn't give an error when trying to commit.

## [0.3.0] - 2016-07-29

### Fixes

- Make sure we're setting a `user.name` for git so it doesn't give an error when trying to commit.

## [0.2.0] - 2016-07-29

### Fixed

- Fix issue where no having a VCR cassette in use caused an error [#11](https://github.com/everypolitician/scraped_page_archive/issues/11).
- Fix issue where `git_remote_get_url_origin` was causing an error when no in a git repo.

## 0.1.0 - 2016-07-28

### Features

- Record http interactions
- Save the interaction to a git repository

[Unreleased]: https://github.com/everypolitician/scraped_page_archive/compare/v0.1.0...HEAD
[0.2.0]: https://github.com/everypolitician/scraped_page_archive/compare/v0.1.0...v0.2.0
[0.3.0]: https://github.com/everypolitician/scraped_page_archive/compare/v0.2.0...v0.3.0
[0.3.1]: https://github.com/everypolitician/scraped_page_archive/compare/v0.3.0...v0.3.1
[0.4.0]: https://github.com/everypolitician/scraped_page_archive/compare/v0.3.1...v0.4.0
