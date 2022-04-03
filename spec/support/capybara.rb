# frozen_string_literal: true

require "capybara/rspec"

Capybara.app = Sinatra::Application
Capybara.server = :puma, { Silent: true }
Capybara.default_driver = :selenium_chrome_headless

# Ignore deprecation warning.
Selenium::WebDriver.logger.ignore(:browser_options)
