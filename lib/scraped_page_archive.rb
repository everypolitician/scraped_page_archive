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

class ScrapedPageArchive
  class Error < StandardError; end

  attr_writer :github_repo_url

  def self.record(*args, &block)
    new.record(*args, &block)
  end

  def record(&block)
    if github_repo_url.nil?
      warn "Could not determine git repo for 'scraped_page_archive' to use.\n\n" \
        "See https://github.com/everypolitician/scraped_page_archive#usage for details."
      return block.call
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
      git.commit(message)
    end
    # FIXME: Auto-pushing should be optional if the user wants to manually do it at the end.
    git.push('origin', branch_name)
    ret
  end

  def open_from_archive(url, *args)
    git.chdir do
      filename = filename_from_url(url.to_s)
      meta = YAML.load_file(filename + '.yml') if File.exist?(filename + '.yml')
      response_body = File.read(filename + '.html') if File.exist?(filename + '.html')
      unless meta && response_body
        fail Error, "No archived copy of #{url} found."
      end
      response_from(meta, response_body)
    end
  end

  def filename_from_url(url)
    File.join(URI.parse(url).host, Digest::SHA1.hexdigest(url))
  end

  def response_from(meta, response_body)
    response = StringIO.new(response_body)
    headers = Hash[meta['response']['headers'].map { |k, v| [k.downcase, v] }]
    response.instance_variable_set(:"@meta", Hash[headers.map { |k, v| [k, v.join(',')] }])
    response.instance_variable_set(:"@metas", headers)
    response.instance_variable_set(:"@base_uri", meta['request']['uri'])
    response.instance_variable_set(:"@status", meta['response']['status'].values.map(&:to_s))

    def response.meta
      @meta
    end

    def response.metas
      @metas
    end

    def response.base_uri
      URI.parse(@base_uri.to_s)
    end

    def response.content_type
      @meta['content-type']
    end

    def response.charset
      @meta['charset']
    end

    def response.content_encoding
      @meta['content-encoding']
    end

    def response.last_modified
      @meta['last-modified']
    end

    def response.status
      @status
    end

    response
  end

  # TODO: This should be configurable.
  def branch_name
    @branch_name ||= 'scraped-pages-archive'
  end

  def git
    @git ||= Git.clone(git_url, tmpdir).tap do |g|
      g.config('user.name', "scraped_page_archive gem #{ScrapedPageArchive::VERSION}")
      g.config('user.email', "scraped_page_archive-#{ScrapedPageArchive::VERSION}@scrapers.everypolitician.org")
      VCR::Archive::Persister.storage_location = g.dir.path
      if g.branches[branch_name] || g.branches["origin/#{branch_name}"]
        g.checkout(branch_name)
      else
        g.chdir do
          # FIXME: It's not currently possible to create an orphan branch with ruby-git
          # @see https://github.com/schacon/ruby-git/pull/140
          system("git checkout --orphan #{branch_name}")
          system("git rm --quiet -rf .")
        end
        g.commit("Initial commit", allow_empty: true)
      end
    end
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
    @github_repo_url ||= (ENV['MORPH_SCRAPER_CACHE_GITHUB_REPO_URL'] || git_remote_get_url_origin)
  end

  def git_remote_get_url_origin
    remote_url = `git config remote.origin.url`.chomp
    return nil unless $?.success?
    remote_url
  end
end
