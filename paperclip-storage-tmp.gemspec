# encoding: utf-8
require File.expand_path('../lib/paperclip-storage-tmp/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Olek Janiszewski']
  gem.email         = ['olek.janiszewski@gmail.com']
  gem.description   = %q{Store Paperclip attachments in your temporary directory}
  gem.summary       = %q{Keep your tests clean by isolating test attachments from development, and between tests}
  gem.homepage      = 'https://github.com/exviva/paperclip-storage-tmp'

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.name          = 'paperclip-storage-tmp'
  gem.require_paths = ['lib']
  gem.version       = Paperclip::Storage::Tmp::VERSION

  gem.add_runtime_dependency 'paperclip', '~> 2.0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'sqlite3'
end
