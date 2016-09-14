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

## How it works

This gem clones the GitHub repository where the app using the gem lives. Then it  creates an orphan branch named `'scraped-pages-archive'` in GitHub and it commits to it on behalf of `scraped_page_archive gem CURRENT-VERSION`, storing the requests/responses made by the app.


## Usage


### Running locally

#### Use with open-uri

If you would like to have your http requests automatically recorded when using open-uri and running your app locally, do the following:

```ruby
require 'scraped_page_archive/open-uri'
response = open('http://example.com/')
# Use the response...
```

### Running somewhere else

If you are not running your app locally, then you need some extra configuration, like the url to your repo and an environment variable to set a GitHub access token. This is because, as opposed to running it locally, the gem won't know what repo it's running within, and it also won't have credentials to write to the repo.

#### Use with third party platforms

If you are using a platform to run your app (for example, Heroku), that needs an explicit url to your app, you can set it to be the URL of the Github repo you're going to write to, together with the GitHub token, using the following:

```ruby
require 'scraped_page_archive'
ScrapedPageArchive.github_repo_url = 'https://YOUR_GITHUB_TOKEN@github.com/tmtmtmtm/estonia-riigikogu'
# or ScrapedPageArchive.github_repo_url = ENV['FOO']
```

You can [generate a GitHub access token here](https://github.com/settings/tokens). It will  need to have the `repo` permission checked.

> Remember not to share your GitHub access token. Don't include it in your code, especially if it lives in a public repo.


#### Use with Morph

If you're using the excellent [morph.io](https://morph.io), which also requires an explicit url, just set an environment variable there with the url to your repo and the GitHub token. Then you can set the `MORPH_SCRAPER_CACHE_GITHUB_REPO_URL` environment variable to your git url:

| Name                                  | Value                                                           |
|---------------------------------------|-----------------------------------------------------------------|
| `MORPH_SCRAPER_CACHE_GITHUB_REPO_URL` | `https://YOUR_GITHUB_TOKEN@github.com/tmtmtmtm/estonia-riigikogu` |

Finally, require the gem and use it. For example, if you are using `open-uri`, check out the previous section.


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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/everypolitician/scraped_page_archive.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT)
