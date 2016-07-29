$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'scraped_page_archive'

require 'minitest/autorun'

class Minitest::Spec
  def with_tmp_dir(&block)
    Dir.mktmpdir do |tmp_dir|
      Dir.chdir(tmp_dir, &block)
    end
  end
end
