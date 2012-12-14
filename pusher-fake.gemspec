Gem::Specification.new do |s|
  s.name        = "pusher-fake"
  s.version     = "0.4.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tristan Dunn"]
  s.email       = "hello@tristandunn.com"
  s.homepage    = "http://github.com/tristandunn/pusher-fake"
  s.summary     = "A fake Pusher server for development and testing."
  s.description = "A fake Pusher server for development and testing."
  s.license     = "MIT"

  s.files        = Dir["lib/**/*"].to_a
  s.test_files   = Dir["{features,spec}/**/*"].to_a
  s.require_path = "lib"

  s.add_dependency "em-http-request", "1.0.3"
  s.add_dependency "em-websocket",    "0.3.8"
  s.add_dependency "thin",            "1.5.0"
  s.add_dependency "multi_json",      "1.5.0"

  s.add_development_dependency "bourne",          "1.3.0"
  s.add_development_dependency "capybara-webkit", "0.13.0"
  s.add_development_dependency "cucumber",        "1.2.1"
  s.add_development_dependency "pusher",          "0.11.1"
  s.add_development_dependency "rake",            "10.0.3"
  s.add_development_dependency "redcarpet",       "2.2.2"
  s.add_development_dependency "rspec",           "2.12.0"
  s.add_development_dependency "sinatra",         "1.3.3"
  s.add_development_dependency "yard",            "0.8.3"
end
