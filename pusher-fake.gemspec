# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "pusher-fake"
  s.version     = "1.12.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tristan Dunn"]
  s.email       = "hello@tristandunn.com"
  s.homepage    = "https://github.com/tristandunn/pusher-fake"
  s.summary     = "A fake Pusher server for development and testing."
  s.description = "A fake Pusher server for development and testing."
  s.license     = "MIT"

  s.files        = Dir["lib/**/*"].to_a
  s.test_files   = Dir["spec/**/*"].to_a
  s.executables << "pusher-fake"
  s.require_path = "lib"

  s.required_ruby_version = ">= 2.3"

  s.add_dependency "em-http-request", "~> 1.1"
  s.add_dependency "em-websocket",    "~> 0.5"
  s.add_dependency "multi_json",      "~> 1.6"
  s.add_dependency "thin",            "~> 1.5"

  s.add_development_dependency "poltergeist",   "1.18.1"
  s.add_development_dependency "pusher",        "1.3.3"
  s.add_development_dependency "rake",          "12.3.2"
  s.add_development_dependency "rspec",         "3.8.0"
  s.add_development_dependency "rubocop",       "0.72.0"
  s.add_development_dependency "rubocop-rspec", "1.33.0"
  s.add_development_dependency "sinatra",       "2.0.5"
  s.add_development_dependency "yard",          "0.9.20"
end
