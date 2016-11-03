# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [0.5.0] - 2016-11-03

### Fixes

- Avoid recloning the whole repo for each request by caching the `ScrapedPageArchive` instance in the `open-uri` and `capybara` adapters.

### Changed

- The git storage logic has been pulled into its own class. This means that you need to pass a `ScrapedPageArchive::GitStorage` instance to the `ScrapedPageArchive` constructor if you're using the class directly. See the ["Running on other platforms" section in README.md](README.md#running-on-other-platforms) for more details.

## [0.4.1] - 2016-08-15

### Fixes

- Fix for Ruby 2.0.0 to ensure we work with the older open-uri implementation, which expects all header values to be strings. [#29](https://github.com/everypolitician/scraped_page_archive/pull/29).

## [0.4.0] - 2016-08-04

### Features

- Added support for Capybara Poltergeist driver
- You can now use the `ScrapedPageArchive#open_from_archive` method to retrieve a page from the archive.

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
[0.4.1]: https://github.com/everypolitician/scraped_page_archive/compare/v0.4.0...v0.4.1
[0.5.0]: https://github.com/everypolitician/scraped_page_archive/compare/v0.4.1...v0.5.0
