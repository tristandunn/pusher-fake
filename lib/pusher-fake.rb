require "em-http-request"
require "em-websocket"
require "multi_json"
require "openssl"
require "thin"

require "pusher-fake/channel"
require "pusher-fake/channel/public"
require "pusher-fake/channel/private"
require "pusher-fake/channel/presence"
require "pusher-fake/configuration"
require "pusher-fake/connection"
require "pusher-fake/server"
require "pusher-fake/server/application"
require "pusher-fake/webhook"

module PusherFake
  # The current version string.
  VERSION = "0.10.0"

  # Call this method to modify the defaults.
  #
  # @example
  #   PusherFake.configure do |configuration|
  #     configuration.port = 443
  #   end
  #
  # @yield [Configuration] The current configuration.
  def self.configure
    yield(configuration)
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
    <<-EOS
      new Pusher(#{configuration.key.to_json}, #{configuration.to_options(options).to_json})
    EOS
  end
end
