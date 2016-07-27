require 'scraped_page_archive/version'
require 'vcr'
require 'vcr/archive'

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_serializers[:vcr_archive] = VCR::Archive::Serializer
  config.cassette_persisters[:vcr_archive] = VCR::Archive::Persister
  config.default_cassette_options = { serialize_with: :vcr_archive, persist_with: :vcr_archive, record: :all }
end

module ScrapedPageArchive
  extend self

  attr_writer :github_repo_url

  def record(&block)
    if github_repo_url.nil?
      warn "Could not determine git repo for 'scraped_page_archive' to use.\n\n" \
        "See https://github.com/everypolitician/scraped_page_archive#usage for details."
      return
    end
    VCR::Archive.git_repository_url = git_url
    VCR.use_cassette('', &block)
  end

  def git_url
    @git_url ||= begin
      url = URI.parse(github_repo_url)
      url.password = ENV['SCRAPED_PAGE_ARCHIVE_GITHUB_TOKEN']
      url.to_s
    end
  end

  def github_repo_url
    @github_repo_url ||= (git_remote_get_url_origin || ENV['MORPH_SCRAPER_CACHE_GITHUB_REPO_URL'])
  end

  def git_remote_get_url_origin
    @git_remote_get_url_origin ||= begin
      remote_url = `git remote get-url origin`.chomp
      remote_url.empty? ? nil : remote_url
    end
  end
end
