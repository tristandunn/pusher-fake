module PusherFake
  class Server
    # Start the WebSocket server.
    def self.start
      EventMachine::WebSocket.start(options) do |socket|
        socket.onopen do
          connection = Connection.new(socket)
          connection.establish

          socket.onmessage do |data|
            connection.process(data)
          end
        end
      end
    end

    private

    def self.configuration
      PusherFake.configuration
    end

    def self.options
      { host: configuration.host,
        port: configuration.port }
    end
  end
end
