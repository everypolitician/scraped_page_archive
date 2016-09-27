require 'git'
require 'English'

class ScrapedPageArchive
  class GitStorage
    attr_writer :github_repo_url

    # FIXME: This should be refactored so it doesn't have as much knowledge about
    # the locations of files on the filesystem.
    def save
      # NOTE: This is a workaround for a ruby-git bug.
      # @see https://github.com/schacon/ruby-git/issues/23
      git.status.changed.each { git.diff.entries }

      files = (git.status.changed.keys + git.status.untracked.keys)
      return ret unless files.any?
      # For each interaction, commit the yml and html along with the correct commit message.
      files.select { |f| f.end_with?('.yml') }.each do |f|
        interaction = git.chdir { YAML.load_file(f) }
        message = "#{interaction['response']['status'].values_at('code', 'message').join(' ')} #{interaction['request']['uri']}"
        git.add([f, f.sub(/\.yml$/, '.html')])
        git.commit(message)
      end
      # FIXME: Auto-pushing should be optional if the user wants to manually do it at the end.
      git.push('origin', branch_name)
    end

    # TODO: This should be configurable.
    def branch_name
      @branch_name ||= 'scraped-pages-archive'
    end

    def git
      @git ||= Git.clone(git_url, tmpdir).tap do |g|
        g.config('user.name', "scraped_page_archive gem #{ScrapedPageArchive::VERSION}")
        g.config('user.email', "scraped_page_archive-#{ScrapedPageArchive::VERSION}@scrapers.everypolitician.org")
        if g.branches[branch_name] || g.branches["origin/#{branch_name}"]
          g.checkout(branch_name)
        else
          g.chdir do
            # FIXME: It's not currently possible to create an orphan branch with ruby-git
            # @see https://github.com/schacon/ruby-git/pull/140
            system("git checkout --orphan #{branch_name}")
            system('git rm --quiet -rf .')
          end
          g.commit('Initial commit', allow_empty: true)
        end
      end
    end

    def path
      git.dir.path
    end

    def tmpdir
      @tmpdir ||= Dir.mktmpdir
    end

    def chdir(&block)
      git.chdir(&block)
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
      return nil unless $CHILD_STATUS.success?
      remote_url
    end
  end
end