module PusherFake
  class Configuration
    # @return [String] The Pusher Applicaiton ID. (Defaults to +PUSHER_APP_ID+.)
    attr_accessor :app_id

    # @return [String] The Pusher API key. (Defaults to +PUSHER_API_KEY+.)
    attr_accessor :key

    # @return [String] The Pusher API token. (Defaults to +PUSHER_API_SECRET+.)
    attr_accessor :secret

    # Options for the socket server. See +EventMachine::WebSocket.start+ for options.
    #
    # @return [Hash] Options for the socket server.
    attr_accessor :socket_options

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
      self.secret   = "PUSHER_API_SECRET"
      self.webhooks = []

      self.socket_options = { host: "127.0.0.1", port: 8080 }
      self.web_options    = { host: "127.0.0.1", port: 8081 }
    end

    # Set the host on which the socket server listens.
    #
    # @deprecated Please use {#socket_options} +Hash+ instead.
    # @param host String
    def socket_host=(host)
      warn "[DEPRECATION] `socket_host=` is deprecated.  Please use `socket_options=` instead."

      socket_options[:host] = host
    end

    # Set the port on which the socket server listens.
    #
    # @deprecated Please use {#socket_options} +Hash+ instead.
    # @param port Integer
    def socket_port=(port)
      warn "[DEPRECATION] `socket_port=` is deprecated.  Please use `socket_options=` instead."

      socket_options[:port] = port
    end

    # Set the host on which the web server listens.
    #
    # @deprecated Please use {#web_options} +Hash+ instead.
    # @param host String
    def web_host=(host)
      warn "[DEPRECATION] `web_host=` is deprecated.  Please use `web_options=` instead."

      web_options[:host] = host
    end

    # Set the port on which the web server listens.
    #
    # @deprecated Please use {#web_options} +Hash+ instead.
    # @param port Integer
    def web_port=(port)
      warn "[DEPRECATION] `web_port=` is deprecated.  Please use `web_options=` instead."

      web_options[:port] = port
    end

    # Convert the configuration to a hash sutiable for Pusher JS options.
    #
    # @param [Hash] options Custom options for Pusher client.
    def to_options(options = {})
      options.merge({
        wsHost: socket_options[:host],
        wsPort: socket_options[:port]
      })
    end
  end
end
