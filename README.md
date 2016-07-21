# ScrapedPageArchive

Add this gem to your Ruby scraper and it will automatically override calls to `open-uri`'s `open` method
and cache the response in a branch within your git repository.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scraped_page_archive', git: 'https://github.com/everypolitician/scraped_page_archive', branch: 'master'
```

And then execute:

    $ bundle

## Usage

First require the library:

```ruby
require 'scraped_page_archive'
```

Then configure the github url to clone. This will need to have a GitHub token embedded in it, you can [generate a new one here](https://github.com/settings/tokens). It will need to have the `repo` permission checked.

If you're using the excellent [morph.io](https://morph.io) then you can set the `MORPH_SCRAPER_CACHE_GITHUB_REPO_URL` environment variable to your git url:

| Name                                  | Value                                                           |
|---------------------------------------|-----------------------------------------------------------------|
| `MORPH_SCRAPER_CACHE_GITHUB_REPO_URL` | `https://githubtokenhere@github.com/tmtmtmtm/estonia-riigikogu` |

You can also set this to any value (including another environment variable of your choosing) with the following:

```ruby
ScrapedPageArchive::GitBranchCache.instance.github_repo_url = 'https://githubtokenhere@github.com/tmtmtmtm/estonia-riigikogu'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/everypolitician/scraped_page_archive.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
