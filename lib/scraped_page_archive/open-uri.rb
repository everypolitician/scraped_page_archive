# Monkey patch open-uri to record http requests automatically.
require 'open-uri'
require 'scraped_page_archive'

module OpenURI
  class << self
    alias __open_uri open_uri
    def open_uri(*args, &block)
      ScrapedPageArchive.record { __open_uri(*args, &block) }
    end
  end
end
