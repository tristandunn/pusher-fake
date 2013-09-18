module PusherFake
  class Configuration
    # @return [String] The Pusher Applicaiton ID. (Defaults to +PUSHER_APP_ID+.)
    attr_accessor :app_id

    # @return [String] The Pusher API key. (Defaults to +PUSHER_API_KEY+.)
    attr_accessor :key

    # @return [String] The Pusher API token. (Defaults to +PUSHER_API_SECRET+.)
    attr_accessor :secret

    # @return [Hash] Options for the socket server.
    attr_accessor :socket_options

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
    # @deprecated
    # @param host String
    def socket_host=(host)
      socket_options[:host] = host
    end

    # Set the port on which the socket server listens.
    #
    # @deprecated
    # @param port Integer
    def socket_port=(port)
      socket_options[:port] = port
    end

    # Set the host on which the web server listens.
    #
    # @deprecated
    # @param host String
    def web_host=(host)
      web_options[:host] = host
    end

    # Set the port on which the web server listens.
    #
    # @deprecated
    # @param port Integer
    def web_port=(port)
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
