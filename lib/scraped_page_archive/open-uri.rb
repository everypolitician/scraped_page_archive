# Monkey patch open-uri to record http requests automatically.
require 'open-uri'
require 'scraped_page_archive'

module OpenURI
  class << self
    alias __open_uri open_uri
    def open_uri(*args, &block)
      scraped_page_archive.record { __open_uri(*args, &block) }
    end

    def scraped_page_archive
      @scraped_page_archive ||= ScrapedPageArchive.new(ScrapedPageArchive::GitStorage.new)
    end
  end
end
