require "capybara/rspec"

Capybara.app = Sinatra::Application
Capybara.default_driver = :webkit

Capybara::Webkit.configure(&:block_unknown_urls)
