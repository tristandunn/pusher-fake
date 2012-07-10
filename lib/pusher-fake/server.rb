module PusherFake
  module Server
    # Start the servers.
    #
    # @see start_socket_server
    # @see start_web_server
    def self.start
      EventMachine.run do
        start_web_server
        start_socket_server
      end
    end

    # Start the WebSocket server.
    def self.start_socket_server
      EventMachine::WebSocket.start(socket_server_options) do |socket|
        socket.onopen do
          connection = Connection.new(socket)
          connection.establish

          socket.onmessage do |data|
            connection.process(data)
          end
          socket.onclose do
            Channel.remove(connection)
          end
        end
      end
    end

    # Start the web server.
    def self.start_web_server
      Thin::Logging.silent = true
      Thin::Server.start(configuration.web_host, configuration.web_port, Application)
    end

    private

    # Convenience method for access the configuration object.
    #
    # @return [Configuration] The configuration object.
    def self.configuration
      PusherFake.configuration
    end

    # Return a hash of options for the socket server based on
    # the configuration.
    #
    # @return [Hash] The socket server configuration options.
    def self.socket_server_options
      { host: configuration.socket_host,
        port: configuration.socket_port }
    end
  end
end
