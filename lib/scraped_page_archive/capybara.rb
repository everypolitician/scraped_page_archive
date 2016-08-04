# Monkey patch capybara poltergiest driver to record http requests automatically.
require 'capybara/poltergeist'
require 'scraped_page_archive'

module Capybara::Poltergeist
  class Driver
    alias __visit visit

    def sha_url(url)
      Digest::SHA1.hexdigest url.gsub(/_piref[\d_]+\./, '')
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
        'request' => {
          'method' => 'get', # assume this as no way to access it
          'uri' => url
        },
        'response' => {
          'status' => {
            'message' => page.status_code == 200 ? 'OK' : 'NOT OK',
            'code' => page.status_code
          },
          'date' => [ page.response_headers['Date'] ]
        }
      }
    end

    def save_request(url)
      html_path, yaml_path = get_paths(url)

      File.open(html_path,"w") do |f|
        f.write(page.html)
      end
      File.open(yaml_path,"w") do |f|
        f.write(YAML.dump(get_details(url)))
      end
    end

    def visit(url)
      ScrapedPageArchive.record do
        __visit(url)
        save_request(page.current_url.to_s)
      end
    end
  end
end
