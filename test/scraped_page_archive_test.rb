require 'test_helper'

describe ScrapedPageArchive do
  subject { ScrapedPageArchive.new }

  it 'has a version number' do
    refute_nil ::ScrapedPageArchive::VERSION
  end

  describe '#git_remote_get_url_origin' do
    describe 'in a git repo' do
      it 'returns the origin url of a git repo' do
        with_tmp_dir do
          remote_url = 'https://git.example.org/foo.git'
          `git init`
          `git remote add origin #{remote_url}`
          assert_equal remote_url, subject.git_remote_get_url_origin
        end
      end

      it 'returns nil if there is no origin remote' do
        with_tmp_dir do
          `git init`
          assert_nil subject.git_remote_get_url_origin
        end
      end
    end

    describe 'no git repo' do
      it 'returns nil' do
        with_tmp_dir do
          assert_nil subject.git_remote_get_url_origin
        end
      end
    end
  end

  describe '#record' do
    class MockGit
      def method_missing(*args, &block)
        raise Git::GitExecuteError, "Access token: #{ENV['SCRAPED_PAGE_ARCHIVE_GITHUB_TOKEN']}"
      end
    end

    before do
      @old_access_token = ENV['SCRAPED_PAGE_ARCHIVE_GITHUB_TOKEN']
      ENV['SCRAPED_PAGE_ARCHIVE_GITHUB_TOKEN'] = 'top_secret'
      subject.git = MockGit.new
    end

    after { ENV['SCRAPED_PAGE_ARCHIVE_GITHUB_TOKEN'] = @old_access_token }

    it 'scrubs access token from errors' do
      error = ->{ subject.record }.must_raise Git::GitExecuteError
      error.message.wont_include ENV['SCRAPED_PAGE_ARCHIVE_GITHUB_TOKEN']
    end
  end
end
