module PusherFake
  class Configuration
    # @return [String] The host on which the WebSocket server listens. (Defaults to +127.0.0.1+.)
    attr_accessor :host

    # @return [String] The Pusher API key. (Defaults to +PUSHER_API_KEY+.)
    attr_accessor :key

    # @return [Fixnum] The port on which the WebSocket server listens. (Defaults to +8080+.)
    attr_accessor :port

    # @return [String] The Pusher API token. (Defaults to +PUSHER_API_SECRET+.)
    attr_accessor :secret

    # Instantiated from {PusherFake.configuration}. Sets the defaults.
    def initialize
      self.host   = "127.0.0.1"
      self.key    = "PUSHER_API_KEY"
      self.port   = 8080
      self.secret = "PUSHER_API_SECRET"
    end
  end
end
