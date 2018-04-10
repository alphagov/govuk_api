# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'govuk_api/version'

Gem::Specification.new do |spec|
  spec.name          = "govuk_api"
  spec.version       = GovukApi::VERSION
  spec.authors       = ["GOV.UK Dev"]
  spec.email         = ["govuk-dev@digital.cabinet-office.gov.uk"]

  spec.summary       = "A gem to make it easier to work with GOV.UK APIs"
  spec.description   = "A gem to make it easier to work with GOV.UK APIs"
  spec.homepage      = "https://github.com/alphagov/govuk_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.add_dependency "faraday", "~> 0.14"
  spec.add_dependency "plek", "~> 2.1"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "govuk-lint", "~> 3.7"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.3"
  spec.add_development_dependency "yard"
end
