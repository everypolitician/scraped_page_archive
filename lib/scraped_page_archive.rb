require 'scraped_page_archive/version'
require 'vcr'
require 'git'
require 'vcr/archive'

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_serializers[:vcr_archive] = VCR::Archive::Serializer
  config.cassette_persisters[:vcr_archive] = VCR::Archive::Persister
  config.default_cassette_options = { serialize_with: :vcr_archive, persist_with: :vcr_archive, record: :all }
  config.allow_http_connections_when_no_cassette = true
end

module ScrapedPageArchive
  extend self

  attr_writer :github_repo_url

  def record(&block)
    if github_repo_url.nil?
      warn "Could not determine git repo for 'scraped_page_archive' to use.\n\n" \
        "See https://github.com/everypolitician/scraped_page_archive#usage for details."
      return block.call
    end
    VCR::Archive::Persister.storage_location = git.dir.path
    if git.branches[branch_name] || git.branches["origin/#{branch_name}"]
      git.checkout(branch_name)
    else
      git.chdir do
        # FIXME: It's not currently possible to create an orphan branch with ruby-git
        # @see https://github.com/schacon/ruby-git/pull/140
        system("git checkout --orphan #{branch_name}")
        system("git rm --quiet -rf .")
      end
      git.commit("Initial commit", allow_empty: true)
    end
    ret = VCR.use_cassette('', &block)

    # NOTE: This is a workaround for a ruby-git bug.
    # @see https://github.com/schacon/ruby-git/issues/23
    git.status.changed.each { git.diff.entries }

    files = (git.status.changed.keys + git.status.untracked.keys)
    return ret unless files.any?
    # For each interaction, commit the yml and html along with the correct commit message.
    files.find_all { |f| f.end_with?('.yml') }.each do |f|
      interaction = git.chdir { YAML.load_file(f) }
      message = "#{interaction['response']['status'].values_at('code', 'message').join(' ')} #{interaction['request']['uri']}"
      git.add([f, f.sub(/\.yml$/, '.html')])
      git.commit(message) rescue binding.pry
    end
    # FIXME: Auto-pushing should be optional if the user wants to manually do it at the end.
    git.push('origin', branch_name)
    ret
  end

  # TODO: This should be configurable.
  def branch_name
    @branch_name ||= 'scraped-pages-archive'
  end

  def git
    @git ||= Git.clone(git_url, tmpdir)
  end

  def tmpdir
    @tmpdir ||= Dir.mktmpdir
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
    remote_url = `git config remote.origin.url`.chomp
    return nil unless $?.success?
    remote_url
  end
end
