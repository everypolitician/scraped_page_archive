# ScrapedPageArchive [![Build Status](https://travis-ci.org/everypolitician/scraped_page_archive.svg?branch=master)](https://travis-ci.org/everypolitician/scraped_page_archive) [![Gem Version](https://badge.fury.io/rb/scraped_page_archive.svg)](https://badge.fury.io/rb/scraped_page_archive)

Add this gem to your Ruby scraper and it will automatically capture http requests
and cache the response in a branch within your git repository.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scraped_page_archive'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scraped_page_archive

## Usage

### Running locally

#### Use with open-uri

If you’re running a scraper locally, and the library can auto-detect
what repo it’s in, and find your credentials, all you need to do for an
`open-uri` based scraper is add a `require` line:

```ruby
require 'scraped_page_archive/open-uri'
response = open('http://example.com/')
# Use the response...
```

As your scraper fetches any page it will also commit a copy of the
response (and the headers), into a `scraped-pages-archive` branch.

### Running on other platforms

If you are not running your app locally, or it can’t auto-detect the
information it needs to be able to do the archiving, then you need to
provide some extra configuration — specifically the url to your repo and
a GitHub access token.

[Generate a GitHub access token here](https://github.com/settings/tokens):
it will need to have the `repo` permission checked. Then combine it with
the details of your repo to produce a setting in the form:


```ruby
REPO = 'https://YOUR_GITHUB_TOKEN@github.com/everypolitician-scrapers/kenya-mzalendo'
storage = ScrapedPageArchive::GitStorage.new(REPO)
archive = ScrapedPageArchive.new(storage)
archive.record { open('http://example.com/') }
```

(Though, obviously, you’ll want your own scraper details there rather than
`everypolitician-scrapers/kenya-mzalendo`!)

IMPORTANT: Remember not to share your GitHub access token. Don’t include
it in your code, especially if it lives in a public repo. Normal usage
would be to set this from an environment variable.

#### Use with Morph

If you’re using the excellent [morph.io](https://morph.io), you can set
your repo URL configuration in the "Secret environment variables"
section of the scraper’s Settings page. We automatically check if
`MORPH_SCRAPER_CACHE_GITHUB_REPO_URL` is set — there’s no need to
explicitly set it using `ScrapedPageArchive.github_repo_url` in this
case.


### More complex scenarios

#### Use with the Capybara Poltergeist driver

If you would like to have your http requests automatically recorded when using the Poltergeist driver in Capybara do the following:

```ruby
require 'scraped_page_archive/capybara'
visit('http://example.com/')
# Use the response...
```

It should be possible to adapt this to work with other Capybara drivers
fairly easily.

#### Use with `ScrapedPageArchive.record`

You can have complete control and record http requests by performing them in a block passed to `ScrapedPageArchive.record`:

```ruby
require 'scraped_page_archive'
ScrapedPageArchive.record do
  response = open('http://example.com/')
  # Use the response...
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Note that this does not install Capybara or any drivers so if you want
to work on that you will need to do that.

### Releases

After you've added a new feature or fixed a bug you should release the gem to rubygems.org.

#### Before releasing a new version

- [ ] Is your new feature/bugfix documented in [`CHANGELOG.md`](CHANGELOG.md)?
- [ ] Have you updated `ScrapedPage::VERSION` according to [SemVer](http://semver.org/)?
- [ ] Have added a section for the new version in [`CHANGELOG.md`](CHANGELOG.md)?
- [ ] Are all of the changes that you want included in the release on the `master` branch?

#### Releasing a new version

If you wanted to release version `0.42.0`, for example, you would need to run the following commands:

    git tag -a -m "scraped_page_archive v0.42.0" v0.42.0
    git push origin --tags

Then Travis CI will notice that you've pushed a new tag and will release the new version of the gem.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/everypolitician/scraped_page_archive.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT)
