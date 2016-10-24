require 'test_helper'

describe ScrapedPageArchive do
  it 'has a version number' do
    refute_nil ::ScrapedPageArchive::VERSION
  end

  describe '#git_remote_get_url_origin' do
    subject { ScrapedPageArchive::GitStorage.new }

    describe 'in a git repo' do
      it 'returns the origin url of a git repo' do
        with_tmp_dir do
          remote_url = 'https://git.example.org/foo.git'
          `git init`
          `git remote add origin #{remote_url}`
          assert_equal remote_url, subject.github_repo_url
        end
      end

      it 'returns nil if there is no origin remote' do
        with_tmp_dir do
          `git init`
          assert_nil subject.github_repo_url
        end
      end
    end

    describe 'no git repo' do
      it 'returns nil' do
        with_tmp_dir do
          assert_nil subject.github_repo_url
        end
      end
    end

    describe 'MORPH_SCRAPER_CACHE_GITHUB_REPO_URL' do
      let(:remote_url) { "https://github.com/everypolitician-scrapers/estonia-riigikogu\n" }

      it 'chomps any supplied ENV var' do
        with_tmp_dir do
          original_env = ENV['MORPH_SCRAPER_CACHE_GITHUB_REPO_URL']
          ENV['MORPH_SCRAPER_CACHE_GITHUB_REPO_URL'] = remote_url
          assert_equal remote_url.chomp, subject.github_repo_url
          ENV['MORPH_SCRAPER_CACHE_GITHUB_REPO_URL'] = original_env
        end
      end
    end
  end

  describe '#git_url' do
    subject { ScrapedPageArchive::GitStorage.new }

    describe 'in a git repo where origin is an scp-style "URL"' do
      it 'works as expected' do
        with_tmp_dir do
          remote_url = 'git@github.com:everypolitician-scrapers/random-scraper.git'
          `git init`
          `git remote add origin #{remote_url}`
          assert_equal remote_url, subject.send(:git_url)
        end
      end
    end
  end
end
