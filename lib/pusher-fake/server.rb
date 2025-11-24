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
        server  = Puma::Server.new(Application)

        add_server_listener(server, options)

        Thread.new { server.run }
      end

      private

      # Add a listener to the server, using SSL if configured.
      def add_server_listener(server, options)
        host        = options.delete(:host)
        port        = options.delete(:port)
        ssl_options = options.delete(:ssl_options) if options.delete(:ssl)

        if ssl_options
          server.add_ssl_listener(host, port, ssl_context_for(ssl_options))
        else
          server.add_tcp_listener(host, port)
        end
      end

      # Create an SSL context for the given options.
      def ssl_context_for(ssl_options)
        Puma::MiniSSL::Context.new.tap do |context|
          context.key = ssl_options[:private_key_file]
          context.cert = ssl_options[:cert_chain_file]
        end
      end

      # Force +EventMachine::WebSocket+ to call the chain of trap handlers to
      # ensure other handlers, such as +RSpec+, can interrupt.
      def chain_trap_handlers
        EventMachine::WebSocket.singleton_class.prepend(ChainTrapHandlers)
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
