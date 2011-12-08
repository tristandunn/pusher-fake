require "em-websocket"
require "hmac-sha2"
require "yajl"

require "pusher-fake/channel"
require "pusher-fake/channel/public"
require "pusher-fake/channel/private"
require "pusher-fake/configuration"
require "pusher-fake/connection"
require "pusher-fake/server"
require "pusher-fake/version"

module PusherFake
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
    @@configuration ||= Configuration.new
  end
end
