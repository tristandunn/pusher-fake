# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "pusher-fake"
  s.version     = "6.0.0"
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

  s.required_ruby_version = ">= 3.2"

  s.add_dependency "em-http-request", "~> 1.1"
  s.add_dependency "em-websocket",    "~> 0.5"
  s.add_dependency "multi_json",      "~> 1.6"
  s.add_dependency "mutex_m",         "~> 0.3.0"
  s.add_dependency "thin",            "~> 1"
end
