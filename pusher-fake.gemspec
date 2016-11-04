Gem::Specification.new do |s|
  s.name        = "pusher-fake"
  s.version     = "1.6.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tristan Dunn"]
  s.email       = "hello@tristandunn.com"
  s.homepage    = "https://github.com/tristandunn/pusher-fake"
  s.summary     = "A fake Pusher server for development and testing."
  s.description = "A fake Pusher server for development and testing."
  s.license     = "MIT"

  s.files        = Dir["lib/**/*"].to_a
  s.test_files   = Dir["spec/**/*"].to_a
  s.require_path = "lib"

  s.add_dependency "em-http-request", "~> 1.1"
  s.add_dependency "em-websocket",    "~> 0.5"
  s.add_dependency "thin",            "~> 1.5"
  s.add_dependency "multi_json",      "~> 1.6"

  s.add_development_dependency "capybara-webkit", "1.11.1"
  s.add_development_dependency "pusher",          "1.3.0"
  s.add_development_dependency "rake",            "11.3.0"
  s.add_development_dependency "rspec",           "3.5.0"
  s.add_development_dependency "rubocop",         "0.43.0"
  s.add_development_dependency "rubocop-rspec",   "1.7.0"
  s.add_development_dependency "sinatra",         "1.4.7"
  s.add_development_dependency "yard",            "0.9.5"
end
