require "capybara/rspec"

Capybara.app = Sinatra::Application
Capybara.default_driver = :webkit

Capybara.register_driver(:webkit) do |application|
  Capybara::Webkit::Driver.new(application).tap do |driver|
    driver.block_unknown_urls
  end
end
