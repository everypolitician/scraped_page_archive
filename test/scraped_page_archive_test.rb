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
end
