module PusherFake
  class Configuration
    # @return [String] The host on which the WebSocket server listens. (Defaults to +127.0.0.1+.)
    attr_accessor :host

    # @return [Fixnum] The port on which the WebSocket server listens. (Defaults to +8080+.)
    attr_accessor :port

    # Instantiated from {PusherFake.configuration}. Sets the defaults.
    def initialize
      self.host = "127.0.0.1"
      self.port = 8080
    end
  end
end
