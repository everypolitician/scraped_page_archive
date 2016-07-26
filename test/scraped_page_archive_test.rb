require 'test_helper'

class ScrapedPageArchiveTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ScrapedPageArchive::VERSION
  end

  def mock_archiver
    @mock_archiver ||= Minitest::Mock.new
  end

  def setup
    ScrapedPageArchive.archiver = mock_archiver
  end

  def test_archiver_is_called
    example_url = 'http://example.org'
    mock_archiver.expect :archive!, nil do |url, &block|
      assert_equal example_url, url
      assert_equal 'block result', block.call
    end
    ScrapedPageArchive.archive!(example_url) { |_| 'block result' }
    mock_archiver.verify
  end
end
