module PusherFake
  class Server
    # Start the WebSocket server.
    def self.start
      configuration = PusherFake.configuration
      options       = { host: configuration.host, port: configuration.port }

      EventMachine::WebSocket.start(options) do |socket|
        socket.onopen { onopen(socket) }
      end
    end

    # Creates and establishes a new connection.
    #
    # @param [EventMachine::WebSocket::Connection] socket The socket object for the connection.
    def self.onopen(socket)
      EventMachine.next_tick do
        connection = Connection.new(socket)
        connection.establish
      end
    end
  end
end
