require "capybara/rspec"

Capybara.app = Sinatra::Application
Capybara.default_driver = :webkit

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end
