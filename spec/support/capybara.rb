# frozen_string_literal: true

require "capybara/rspec"

Capybara.app = PusherFake::Testing::Application.new
Capybara.server = :puma, { Silent: true }
Capybara.default_driver = :selenium_chrome_headless
