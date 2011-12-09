module PusherFake
  class Connection
    # @return [EventMachine::WebSocket::Connection] The socket object for this connection.
    attr_reader :socket

    # Create a new {Connection} object.
    #
    # @param [EventMachine::WebSocket::Connection] socket The socket object for the connection.
    def initialize(socket)
      @socket = socket
    end

    # Emit an event to the connection.
    #
    # @param [String] event The event name.
    # @param [Hash] data The event data.
    def emit(event, data = {}, channel = nil)
      message = { event: event, data: data }
      message[:channel] = channel if channel
      message = Yajl::Encoder.encode(message)

      socket.send(message)
    end

    # Notifies the Pusher client that a connection has been established.
    def establish
      emit("pusher:connection_established", socket_id: socket.object_id)
    end

    # Processes an event.
    #
    # @param [String] data The event data as JSON.
    def process(data)
      message      = Yajl::Parser.parse(data, symbolize_keys: true)
      data         = message[:data]
      event        = message[:event]
      channel_name = message[:channel] || data.delete(:channel)
      channel      = Channel.factory(channel_name)

      case event
      when "pusher:subscribe"
        channel.add(self, data)
      when "pusher:unsubscribe"
        channel.remove(self)
      else
        channel.emit(event, data) if channel.includes?(self)
      end
    end
  end
end
