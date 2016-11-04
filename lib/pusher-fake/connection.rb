module PusherFake
  # A client connection.
  class Connection
    # Name matcher for client events.
    CLIENT_EVENT_MATCHER = /\Aclient-(.+)\z/

    # @return [EventMachine::WebSocket::Connection] Socket for the connection.
    attr_reader :socket

    # Create a new {Connection} object.
    #
    # @param [EventMachine::WebSocket::Connection] socket Connection object.
    def initialize(socket)
      @socket = socket
    end

    # The ID of the connection.
    #
    # @return [Integer] The object ID of the socket.
    def id
      parts = socket.object_id.to_s.split("")
      parts = parts.each_slice(parts.length / 2).to_a

      [parts.first.join(""), parts.last.join("")].join(".")
    end

    # Emit an event to the connection.
    #
    # @param [String] event The event name.
    # @param [Hash] data The event data.
    # @param [String] channel The channel name.
    def emit(event, data = {}, channel = nil)
      message = { event: event, data: MultiJson.dump(data) }
      message[:channel] = channel if channel

      PusherFake.log("SEND #{id}: #{message}")

      socket.send(MultiJson.dump(message))
    end

    # Notify the Pusher client that a connection has been established.
    def establish
      emit("pusher:connection_established",
           socket_id: id, activity_timeout: 120)
    end

    # Process an event.
    #
    # @param [String] data The event data as JSON.
    def process(data)
      message = MultiJson.load(data, symbolize_keys: true)
      event   = message[:event]

      PusherFake.log("RECV #{id}: #{message}")

      if event =~ CLIENT_EVENT_MATCHER
        process_trigger(event, message)
      else
        process_event(event, message)
      end
    end

    private

    def channel_for(message)
      Channel.factory(message[:channel] || message[:data][:channel])
    end

    def process_event(event, message)
      if event == "pusher:subscribe"
        channel_for(message).add(self, message[:data])
      elsif event == "pusher:unsubscribe"
        channel_for(message).remove(self)
      elsif event == "pusher:ping"
        emit("pusher:pong")
      end
    end

    def process_trigger(event, message)
      channel = channel_for(message)

      return unless channel.is_a?(Channel::Private) && channel.includes?(self)

      channel.emit(event, message[:data], socket_id: id)

      trigger(channel, id, event, message[:data])
    end

    def trigger(channel, id, event, data)
      Thread.new do
        hook = { event: event, channel: channel.name, socket_id: id }
        hook[:data] = MultiJson.dump(data) if data

        if channel.is_a?(Channel::Presence)
          hook[:user_id] = channel.members[self][:user_id]
        end

        channel.trigger("client_event", hook)
      end
    end
  end
end
