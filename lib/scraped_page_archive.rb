require 'scraped_page_archive/version'
require 'scraped_page_archive/git_storage'
require 'vcr'
require 'vcr/archive'

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_serializers[:vcr_archive] = VCR::Archive::Serializer
  config.cassette_persisters[:vcr_archive] = VCR::Archive::Persister
  config.default_cassette_options = { serialize_with: :vcr_archive, persist_with: :vcr_archive, record: :all }
  config.allow_http_connections_when_no_cassette = true
end

class ScrapedPageArchive
  class Error < StandardError; end

  def self.record(*args, &block)
    new(GitStorage.new).record(*args, &block)
  end

  attr_reader :storage

  def initialize(storage)
    @storage = storage
  end

  def record(&block)
    return yield unless storage.valid?
    VCR::Archive::Persister.storage_location = storage.path
    ret = VCR.use_cassette('', &block)
    storage.save
    ret
  end

  def open_from_archive(url)
    storage.chdir do
      filename = filename_from_url(url.to_s)
      meta = YAML.load_file(filename + '.yml') if File.exist?(filename + '.yml')
      response_body = File.read(filename + '.html') if File.exist?(filename + '.html')
      unless meta && response_body
        fail Error, "No archived copy of #{url} found."
      end
      response_from(meta, response_body)
    end
  end

  def filename_from_url(url)
    File.join(URI.parse(url).host, Digest::SHA1.hexdigest(url))
  end

  def response_from(meta, response_body)
    StringIO.new(response_body).tap do |response|
      OpenURI::Meta.init(response)
      meta['response']['headers'].each { |k, v| response.meta_add_field(k, v.join(', ')) }
      response.status = meta['response']['status'].values.map(&:to_s)
      response.base_uri = URI.parse(meta['request']['uri'])
    end
  end
end
