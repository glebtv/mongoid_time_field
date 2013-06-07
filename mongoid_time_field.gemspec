# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid_time_field/version'

Gem::Specification.new do |spec|
  spec.name          = "mongoid_time_field"
  spec.version       = MongoidTimeField::VERSION
  spec.authors       = ["glebtv"]
  spec.email         = ["glebtv@gmail.com"]
  spec.description   = %q{Time field (stored as integer with no date) for Mongoid}
  spec.summary       = %q{Time field for Mongoid}
  spec.homepage      = "http://github.com/glebtv/mongoid_time_field"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'mongoid', [">= 3.0.0"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'database_cleaner'
end
