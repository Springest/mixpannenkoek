# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mixpannenkoek/version'

Gem::Specification.new do |spec|
  spec.name          = "mixpannenkoek"
  spec.version       = Mixpannenkoek::VERSION
  spec.authors       = ["Derek Kraan"]
  spec.email         = ["derek.kraan@gmail.com"]
  spec.summary       = %q{Sugar for the mixpanel-client gem}
  spec.description   = %q{Implements a fluent interface for writing queries for the mixpanel API. Also includes ActiveRecord-like features like default scoping.}
  spec.homepage      = "https://github.com/Springest/mixpannenkoek"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'mixpanel_client', "~> 4.1.0"

  spec.add_development_dependency "bundler", "~> 1.4"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
