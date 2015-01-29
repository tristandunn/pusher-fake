require "bundler/setup"
require "capybara/cucumber"

Bundler.require(:default, :development)

Capybara.app = Sinatra::Application
Capybara.javascript_driver = :webkit

RSpec.configure do |config|
  config.expect_with :rspec do |rspec|
    rspec.syntax = :expect
  end
end

Capybara.register_driver(:webkit) do |application|
  Capybara::Webkit::Driver.new(application).tap do |driver|
    driver.block_unknown_urls
  end
end
