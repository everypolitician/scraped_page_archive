# Monkey patch capybara poltergiest driver to record http requests automatically.
require 'capybara/poltergeist'
require 'scraped_page_archive'

module Capybara::Poltergeist
  class Driver
    alias __visit visit

    def sha_url(url)
      Digest::SHA1.hexdigest url.gsub(/_piref[\d_]+\./, '')
    end

    def get_path(url)
      base_dir = VCR::Archive::Persister.storage_location
      page_url = URI(page.current_url)
      page_url = URI(page.current_url)
      dir = File.join(base_dir, page_url.host)
      FileUtils.mkdir_p(dir)
      sha = sha_url(page_url.to_s)
      File.join(dir, sha)
    end

    def get_details
      {
        'request' => {
          'method' => 'get',
          'uri' => page.current_url.to_s
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

    def visit(url)
      ScrapedPageArchive.record do
        __visit(url)

        base_path = get_path(url)
        html_path = base_path + '.html'
        yaml_path = base_path + '.yml'

        details = get_details()

        File.open(html_path,"w") do |f|
          f.write(page.html)
        end
        File.open(yaml_path,"w") do |f|
          f.write(YAML.dump(details))
        end
      end
    end
  end
end
