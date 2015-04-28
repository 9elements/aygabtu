# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aygabtu/version'

Gem::Specification.new do |spec|
  spec.name          = "aygabtu"
  spec.version       = Aygabtu::VERSION
  spec.authors       = ["Thomas Stratmann"]
  spec.email         = ["thomas.stratmann@9elements.com"]
  spec.summary       = %q{Feature test generator for GET requests}
  spec.description   = %q{Feature test generator for GET requests, using Capybara and RSpec}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec-rails"
  spec.add_dependency "capybara"
end
