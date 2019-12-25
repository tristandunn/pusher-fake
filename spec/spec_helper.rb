# frozen_string_literal: true

require "bundler/setup"

Bundler.require(:default, :development)

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
