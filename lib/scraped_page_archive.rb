require 'singleton'

require 'scraped_page_archive/version'

module ScrapedPageArchive
  class GitBranchCache
    include Singleton

    attr_writer :github_repo_url

    def cache_response(url)
      if github_repo_url.nil?
        warn "Could not determine git repo for 'scraped_page_archive' to use.\n\n" \
          "See https://github.com/everypolitician/scraped_page_archive#usage for details."
        return yield(url)
      end
      clone_repo_if_missing!
      Dir.chdir(archive_directory) do
        create_or_checkout_archive_branch!
        OpenURI::Cache.cache_path = archive_directory
        response = yield(url)
        message = "#{response.status.join(' ')} #{url}"
        system("git add .")
        system("git commit --allow-empty --message='#{message}'")
        system("git push --quiet origin #{branch_name}")
        response
      end
    end

    def clone_repo_if_missing!
      unless File.directory?(archive_directory)
        warn "Cloning archive repo into /tmp"
        system("git clone #{github_repo_url} #{archive_directory}")
      end
    end

    def create_or_checkout_archive_branch!
      if system("git rev-parse --verify #{branch_name} > /dev/null 2>&1")
        system("git checkout --quiet -B #{branch_name}")
      else
        system("git checkout --orphan #{branch_name}")
        system("git rm --quiet -rf .")
      end
    end

    def github_repo_url
      @github_repo_url ||= ENV['MORPH_SCRAPER_CACHE_GITHUB_REPO_URL']
    end

    # TODO: This should be configurable
    def refresh_cache?
      true
    end

    # TODO: This should be configurable
    def archive_directory
      @archive_directory ||= '/tmp/scraper-archive'
    end

    # TODO: This should be configurable
    def branch_name
      @branch_name ||= 'scraped-pages-archive'
    end
  end
end

module OpenURI
  class << self
    alias __open_uri open_uri
    def open_uri(url, *args)
      ScrapedPageArchive::GitBranchCache.instance.cache_response(url) do |*open_uri_args|
        __open_uri(*open_uri_args)
      end
    end
  end
end
