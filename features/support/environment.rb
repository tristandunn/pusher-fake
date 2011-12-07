require "rubygems"
require "bundler/setup"
require "capybara/cucumber"

Bundler.require(:default, :development)

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each do |file|
  require file
end

Capybara.app = Sinatra::Application
Capybara.javascript_driver = :webkit
