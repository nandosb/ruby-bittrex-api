# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bittrex/version'

Gem::Specification.new do |spec|
  spec.name          = "bittrex"
  spec.version       = Bittrex::VERSION
  spec.authors       = ["Fernando Serrano"]
  spec.email         = ["nandosb@gmail.com"]
  spec.description   = %q{Ruby Bittrex.com client}
  spec.summary       = %q{Full access to Bittrex.com endpoints}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-byebug'
  spec.add_dependency 'json'
  spec.add_dependency "rest-client"
end