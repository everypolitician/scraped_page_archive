require 'test_helper'

class ScrapedPageArchiveTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ScrapedPageArchive::VERSION
  end
end
