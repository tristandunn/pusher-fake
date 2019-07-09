# frozen_string_literal: true

module PusherFake
  # Socket and web server manager.
  module Server
    autoload :Application, "pusher-fake/server/application"

    class << self
      # Start the servers.
      #
      # @see start_socket_server
      # @see start_web_server
      def start
        EventMachine.run do
          start_web_server
          start_socket_server
        end
      end

      # Start the WebSocket server.
      def start_socket_server
        EventMachine::WebSocket.start(configuration.socket_options) do |socket|
          socket.onopen do
            connection = Connection.new(socket)
            connection.establish

            socket.onmessage { |data| connection.process(data) }
            socket.onclose   { Channel.remove(connection) }
          end
        end
      end

      # Start the web server.
      def start_web_server
        options = configuration.web_options.dup
        host    = options.delete(:host)
        port    = options.delete(:port)

        Thin::Logging.silent = true
        Thin::Server.new(host, port, Application).tap do |server|
          options.each do |key, value|
            server.__send__("#{key}=", value)
          end

          server.start!
        end
      end

      private

      # Convenience method for access the configuration object.
      #
      # @return [Configuration] The configuration object.
      def configuration
        PusherFake.configuration
      end

      # Return a hash of options for the socket server based on
      # the configuration.
      #
      # @return [Hash] The socket server configuration options.
      def socket_server_options
        { host: configuration.socket_host,
          port: configuration.socket_port }
      end
    end
  end
end
