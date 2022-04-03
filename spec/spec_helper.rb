# frozen_string_literal: true

require "bundler/setup"

Bundler.require(:default, :development)

if ENV["CI"] || ENV["COVERAGE"]
  require "simplecov"
  require "simplecov-console"

  SimpleCov.formatter = SimpleCov::Formatter::Console
  SimpleCov.start do
    add_filter("lib/pusher-fake/support")
    add_filter("spec/support")
    enable_coverage :branch
    minimum_coverage line: 100, branch: 100
  end
end

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each do |file|
  require file
end

RSpec.configure do |config|
  config.expect_with :rspec do |rspec|
    rspec.syntax = :expect
  end

  # Raise errors for any deprecations.
  config.raise_errors_for_deprecations!
end
