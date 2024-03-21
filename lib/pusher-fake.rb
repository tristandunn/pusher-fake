# frozen_string_literal: true

require "em-http-request"
require "em-websocket"
require "multi_json"
require "openssl"
require "thin"

# A Pusher fake.
module PusherFake
  # The current version string.
  VERSION = "6.0.0"

  autoload :Channel,       "pusher-fake/channel"
  autoload :Configuration, "pusher-fake/configuration"
  autoload :Connection,    "pusher-fake/connection"
  autoload :Server,        "pusher-fake/server"
  autoload :Webhook,       "pusher-fake/webhook"

  # Call this method to modify the defaults.
  #
  # @example
  #   PusherFake.configure do |configuration|
  #     configuration.port = 443
  #   end
  #
  # @yield [Configuration] The current configuration.
  def self.configure
    yield configuration
  end

  # @return [Configuration] Current configuration.
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Convenience method for the JS to override the Pusher client host and port.
  #
  # @param [Hash] options Custom options for Pusher client.
  # @return [String] JavaScript overriding the Pusher client host and port.
  def self.javascript(options = {})
    arguments = [
      configuration.key,
      configuration.to_options(options)
    ].map(&:to_json).join(",")

    "new Pusher(#{arguments})"
  end

  def self.log(message)
    configuration.logger << "#{message}\n" if configuration.verbose
  end
end
