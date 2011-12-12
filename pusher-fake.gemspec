Gem::Specification.new do |s|
  s.name        = "pusher-fake"
  s.version     = "0.1.0"
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

  s.add_dependency "em-websocket", "0.3.5"
  s.add_dependency "ruby-hmac",    "0.4.0"
  s.add_dependency "thin",         "1.3.1"
  s.add_dependency "yajl-ruby",    "1.1.0"

  s.add_development_dependency "bourne",          "1.0.0"
  s.add_development_dependency "bundler",         "1.1.rc.2"
  s.add_development_dependency "capybara",        "1.1.2"
  s.add_development_dependency "capybara-webkit", "0.7.2"
  s.add_development_dependency "cucumber",        "1.1.3"
  s.add_development_dependency "pusher",          "0.8.5"
  s.add_development_dependency "redcarpet",       "2.0.0"
  s.add_development_dependency "rspec",           "2.7.0"
  s.add_development_dependency "sinatra",         "1.3.1"
  s.add_development_dependency "yard",            "0.7.4"
end
