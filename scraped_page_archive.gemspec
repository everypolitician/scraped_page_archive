# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scraped_page_archive/version'

Gem::Specification.new do |spec|
  spec.name          = 'scraped_page_archive'
  spec.version       = ScrapedPageArchive::VERSION
  spec.authors       = ['Chris Mytton']
  spec.email         = ['chrismytton@gmail.com']

  spec.summary       = 'Archives a copy of scraped web pages into a git branch'
  spec.homepage      = 'https://github.com/everypolitician/scraped_page_archive'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'vcr-archive', '~> 0.3.0'
  spec.add_runtime_dependency 'git', '~> 1.3.0'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry', '~> 0.10.4'
  spec.add_development_dependency 'rubocop', '~> 0.42'
end
