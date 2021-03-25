# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/aws_sns/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-aws_sns'
  spec.version       = Fastlane::AwsSns::VERSION
  spec.author        = %q{Josh Holtz}
  spec.email         = %q{me@joshholtz.com}

  spec.summary       = %q{Creates AWS SNS platform applications}
  spec.homepage      = "https://github.com/fastlane-community/fastlane-plugin-aws_sns"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-sns', '~> 1.0'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 2.144.0'
end
