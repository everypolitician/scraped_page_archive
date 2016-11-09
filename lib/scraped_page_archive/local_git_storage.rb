require 'scraped_page_archive/git_storage'

class ScrapedPageArchive
  class LocalGitStorage < GitStorage
    def initialize(git_repo_path)
      @git_repo_path = git_repo_path
    end

    def git
      @git ||= Git.open(git_repo_path).tap do |g|
        g.config('user.name', "scraped_page_archive gem #{ScrapedPageArchive::VERSION}")
        g.config('user.email', "scraped_page_archive-#{ScrapedPageArchive::VERSION}@scrapers.everypolitician.org")
      end
    end

    private

    attr_reader :git_repo_path
  end
end
