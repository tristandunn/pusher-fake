module PusherFake
  class Configuration
    # @return [String] The Pusher Applicaiton ID. (Defaults to +PUSHER_APP_ID+.)
    attr_accessor :app_id
    
    # @return [String] The Pusher API key. (Defaults to +PUSHER_API_KEY+.)
    attr_accessor :key

    # @return [String] The Pusher API token. (Defaults to +PUSHER_API_SECRET+.)
    attr_accessor :secret

    # @return [String] The host on which the socket server listens. (Defaults to +127.0.0.1+.)
    attr_accessor :socket_host

    # @return [Fixnum] The port on which the socket server listens. (Defaults to +8080+.)
    attr_accessor :socket_port

    # @return [String] The host on which the web server listens. (Defaults to +127.0.0.1+.)
    attr_accessor :web_host

    # @return [Fixnum] The port on which the web server listens. (Defaults to +8081+.)
    attr_accessor :web_port

    # Instantiated from {PusherFake.configuration}. Sets the defaults.
    def initialize
      self.app_id      = "PUSHER_APP_ID"
      self.key         = "PUSHER_API_KEY"
      self.secret      = "PUSHER_API_SECRET"
      self.socket_host = "127.0.0.1"
      self.socket_port = 8080
      self.web_host    = "127.0.0.1"
      self.web_port    = 8081
    end
  end
end
