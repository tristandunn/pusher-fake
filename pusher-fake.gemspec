# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "pusher-fake"
  s.version     = "5.0.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tristan Dunn"]
  s.email       = "hello@tristandunn.com"
  s.homepage    = "https://github.com/tristandunn/pusher-fake"
  s.summary     = "A fake Pusher server for development and testing."
  s.description = "A fake Pusher server for development and testing."
  s.license     = "MIT"
  s.metadata    = {
    "bug_tracker_uri"       => "https://github.com/tristandunn/pusher-fake/issues",
    "changelog_uri"         => "https://github.com/tristandunn/pusher-fake/blob/main/CHANGELOG.markdown",
    "rubygems_mfa_required" => "true"
  }

  s.files        = Dir["lib/**/*"].to_a
  s.executables << "pusher-fake"
  s.require_path = "lib"

  s.required_ruby_version = ">= 3.1"

  s.add_dependency "em-http-request", "~> 1.1"
  s.add_dependency "em-websocket",    "~> 0.5"
  s.add_dependency "multi_json",      "~> 1.6"
  s.add_dependency "thin",            "~> 1"

  s.add_development_dependency "capybara",            "3.40.0"
  s.add_development_dependency "puma",                "6.4.2"
  s.add_development_dependency "pusher",              "2.0.3"
  s.add_development_dependency "rake",                "13.1.0"
  s.add_development_dependency "rspec",               "3.13.0"
  s.add_development_dependency "rubocop",             "1.61.0"
  s.add_development_dependency "rubocop-capybara",    "2.20.0"
  s.add_development_dependency "rubocop-performance", "1.20.2"
  s.add_development_dependency "rubocop-rake",        "0.6.0"
  s.add_development_dependency "rubocop-rspec",       "2.27.1"
  s.add_development_dependency "selenium-webdriver",  "4.18.1"
  s.add_development_dependency "sinatra",             "3.2.0"
  s.add_development_dependency "yard",                "0.9.36"
end
