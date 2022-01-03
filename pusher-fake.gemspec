# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "pusher-fake"
  s.version     = "3.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tristan Dunn"]
  s.email       = "hello@tristandunn.com"
  s.homepage    = "https://github.com/tristandunn/pusher-fake"
  s.summary     = "A fake Pusher server for development and testing."
  s.description = "A fake Pusher server for development and testing."
  s.license     = "MIT"
  s.metadata    = { "rubygems_mfa_required" => "true" }

  s.files        = Dir["lib/**/*"].to_a
  s.test_files   = Dir["spec/**/*"].to_a
  s.executables << "pusher-fake"
  s.require_path = "lib"

  s.required_ruby_version = ">= 2.6"

  s.add_dependency "em-http-request", "~> 1.1"
  s.add_dependency "em-websocket",    "~> 0.5"
  s.add_dependency "multi_json",      "~> 1.6"
  s.add_dependency "thin",            "~> 1.5"

  s.add_development_dependency "capybara",            "3.35.3"
  s.add_development_dependency "puma",                "5.5.2"
  s.add_development_dependency "pusher",              "2.0.2"
  s.add_development_dependency "rake",                "13.0.6"
  s.add_development_dependency "rspec",               "3.10.0"
  s.add_development_dependency "rubocop",             "1.22.1"
  s.add_development_dependency "rubocop-performance", "1.11.5"
  s.add_development_dependency "rubocop-rake",        "0.6.0"
  s.add_development_dependency "rubocop-rspec",       "2.5.0"
  s.add_development_dependency "selenium-webdriver",  "4.0.2"
  s.add_development_dependency "sinatra",             "2.1.0"
  s.add_development_dependency "yard",                "0.9.26"
end
