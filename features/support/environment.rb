require "bundler/setup"
require "capybara/cucumber"

Bundler.require(:default, :development)

Capybara.app = Sinatra::Application
Capybara.javascript_driver = :webkit
