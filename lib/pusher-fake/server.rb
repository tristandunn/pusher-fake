module PusherFake
  class Server
    # Start the WebSocket server.
    def self.start
      configuration = PusherFake.configuration
      options       = { host: configuration.host, port: configuration.port }

      EventMachine::WebSocket.start(options) do |socket|
        connection = Connection.new(socket)

        socket.onopen { onopen(connection) }
      end
    end

    # Creates and establishes a new connection.
    #
    # @param [EventMachine::WebSocket::Connection] socket The socket object for the connection.
    def self.onopen(connection)
      EventMachine.next_tick do
        connection.establish
      end
    end
  end
end
