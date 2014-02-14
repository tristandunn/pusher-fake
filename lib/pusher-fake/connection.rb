module PusherFake
  class Connection
    # Name matcher for client events.
    CLIENT_EVENT_MATCHER  = /\Aclient-(.+)\Z/.freeze

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
    # @param [String] channel The channel name.
    def emit(event, data = {}, channel = nil)
      message = { event: event, data: data }
      message[:channel] = channel if channel

      socket.send(MultiJson.dump(message))
    end

    # Notify the Pusher client that a connection has been established.
    def establish
      emit("pusher:connection_established", socket_id: socket.object_id, activity_timeout: 120)
    end

    # Process an event.
    #
    # @param [String] data The event data as JSON.
    def process(data)
      message = MultiJson.load(data, symbolize_keys: true)
      data    = message[:data]
      event   = message[:event]
      channel = Channel.factory(message[:channel] || data.delete(:channel))

      case event
      when "pusher:subscribe"
        channel.add(self, data)
      when "pusher:unsubscribe"
        channel.remove(self)
      when CLIENT_EVENT_MATCHER
        if channel.is_a?(Channel::Private) && channel.includes?(self)
          channel.emit(event, data, socket_id: socket.object_id)
        end
      end
    end
  end
end
