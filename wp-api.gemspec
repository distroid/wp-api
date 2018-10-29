# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wp/api/version'

Gem::Specification.new do |spec|
  spec.name          = "wp-api"
  spec.version       = WP::API::VERSION
  spec.authors       = ['Colin Young', 'Ryabov Ruslan', 'Audienti Authors']
  spec.email         = ['me@colinyoung.com', 'diserve.it@gmail.com', 'support@audienti.com']
  spec.summary       = %q{Easily access Wordpress blogs that have the new, RESTful WP API 2 plugin installed.}
  spec.description   = %q{Makes it incredibly easy and semantic to access Wordpress blogs that have the new, RESTful WP API plugin installed.}
  spec.homepage      = "https://github.com/omalab/wp-api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'httparty'
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'addressable'
  spec.add_runtime_dependency 'htmlentities'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "yajl-ruby", '~> 1.2.1'
  spec.add_development_dependency "rake", '~> 0'
  spec.add_development_dependency "rspec", '>= 2.0'
  spec.add_development_dependency "rspec-its", '>= 1.0.1'
  spec.add_development_dependency "fakeweb", '~> 1.3', '>= 1.3.0'
end
