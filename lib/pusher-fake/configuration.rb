module PusherFake
  class Configuration
    # @return [String] The Pusher Applicaiton ID. (Defaults to +PUSHER_APP_ID+.)
    attr_accessor :app_id

    # @return [String] The Pusher API key. (Defaults to +PUSHER_API_KEY+.)
    attr_accessor :key

    # @return [IO] An IO instance for verbose logging.
    attr_accessor :logger

    # @return [String] The Pusher API token. (Defaults to +PUSHER_API_SECRET+.)
    attr_accessor :secret

    # Options for the socket server. See +EventMachine::WebSocket.start+ for options.
    #
    # @return [Hash] Options for the socket server.
    attr_accessor :socket_options

    # @return [Boolean] Enable verbose logging.
    attr_accessor :verbose

    # Options for the web server. See +Thin::Server+ for options.
    #
    # @return [Hash] Options for the web server.
    attr_accessor :web_options

    # @return [Array] An array of webhook URLs. (Defaults to +[]+.)
    attr_accessor :webhooks

    # Instantiated from {PusherFake.configuration}. Sets the defaults.
    def initialize
      self.app_id   = "PUSHER_APP_ID"
      self.key      = "PUSHER_API_KEY"
      self.logger   = STDOUT.to_io
      self.secret   = "PUSHER_API_SECRET"
      self.verbose  = false
      self.webhooks = []

      self.socket_options = { host: "127.0.0.1", port: available_port }
      self.web_options    = { host: "127.0.0.1", port: available_port }
    end

    # Convert the configuration to a hash sutiable for Pusher JS options.
    #
    # @param [Hash] options Custom options for Pusher client.
    def to_options(options = {})
      options.merge(
        wsHost: socket_options[:host],
        wsPort: socket_options[:port]
      )
    end

    private

    def available_port
      socket = Socket.new(:INET, :STREAM, 0)
      socket.bind(Addrinfo.tcp("127.0.0.1", 0))
      socket.local_address.ip_port.tap do
        socket.close
      end
    end
  end
end
