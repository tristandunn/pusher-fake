# frozen_string_literal: true

module PusherFake
  # Socket and web server manager.
  module Server
    autoload :Application, "pusher-fake/server/application"
    autoload :ChainTrapHandlers, "pusher-fake/server/chain_trap_handlers"

    class << self
      # Start the servers.
      #
      # @see start_socket_server
      # @see start_web_server
      def start
        chain_trap_handlers

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
            server.__send__(:"#{key}=", value)
          end

          server.start!
        end
      end

      private

      # Force +Thin::Server+ and +EventMachine::WebSocket+ to call the chain of
      # trap handlers to ensure other handles, such as +RSpec+, can interrupt.
      def chain_trap_handlers
        EventMachine::WebSocket.singleton_class.prepend(ChainTrapHandlers)
        Thin::Server.prepend(ChainTrapHandlers)
      end

      # Convenience method for access the configuration object.
      #
      # @return [Configuration] The configuration object.
      def configuration
        PusherFake.configuration
      end
    end
  end
end
