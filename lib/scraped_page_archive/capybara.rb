# Monkey patch capybara poltergiest driver to record http requests automatically.
require 'capybara/poltergeist'
require 'scraped_page_archive'

module Capybara::Poltergeist
  class Browser
    alias __command command

    def sha_url(url)
      Digest::SHA1.hexdigest url
    end

    def base_dir_for_url(url)
      dir = File.join(VCR::Archive::Persister.storage_location, URI(url).host)
      FileUtils.mkdir_p(dir)
      dir
    end

    def get_paths(url)
      base_path = File.join(base_dir_for_url(url), sha_url(url))

      ['.html', '.yml'].map { |x| base_path + x }
    end

    def get_details(url)
      {
        'request'  => {
          'method' => 'get', # assume this as no way to access it
          'uri'    => url,
        },
        'response' => {
          'status' => {
            'message' => status_code == 200 ? 'OK' : 'NOT OK',
            'code'    => status_code,
          },
          'date'   => [response_headers['Date']],
        },
      }
    end

    def save_request(html, details, url)
      html_path, yaml_path = get_paths(url)

      File.open(html_path, 'w') do |f|
        f.write(html)
      end
      File.open(yaml_path, 'w') do |f|
        f.write(YAML.dump(details))
      end
    end

    def command(name, *args)
      result = __command(name, *args)
      # we skip these methods because they are called a lot, don't cause the page
      # to change and having record round them slows things down quite a bit.
      return result if %w[tag_name visible property find body set_js_errors current_url status_code response_headers].include?(name)
      scraped_page_archive.record do
        save_request(body, get_details(current_url), current_url)
      end
      result
    end

    def scraped_page_archive
      @scraped_page_archive ||= ScrapedPageArchive.new(ScrapedPageArchive::GitStorage.new)
    end
  end
end
