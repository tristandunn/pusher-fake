module PusherFake
  module Channel
    class Public
      # @return [Array] Connections in this channel.
      attr_reader :connections

      # @return [String] The channel name.
      attr_reader :name

      # Create a new {Public} object.
      #
      # @param [String] name The channel name.
      def initialize(name)
        @name        = name
        @connections = []
      end

      # Add the connection to the channel if they are authorized.
      #
      # @param [Connection] connection The connection to add.
      # @param [Hash] options The options for the channel.
      # @options options [String] :auth The authentication string.
      def add(connection, options = {})
        if authorized?(connection, options[:auth])
          connection.emit("pusher_internal:subscription_succeeded", {}, name)
          connections.push(connection)
        else
          connection.emit("pusher_internal:subscription_error", {}, name)
        end
      end

      # Determine if the connection is authorized for the channel.
      #
      # @return [true]
      def authorized?(connection, authentication)
        true
      end

      # Emits an event to the channel.
      #
      # @param [String] event The event name.
      # @param [Hash] data Data to emit with the event.
      def emit(event, data)
        connections.each do |connection|
          connection.emit(event, data, name)
        end
      end

      # Determines if the +connection+ is in the channel.
      #
      # @param [Connection] connection The connection.
      # @returns [Boolean] +true+ if the connection is in the channel, +false+ otherwise.
      def includes?(connection)
        connections.index(connection)
      end
    end
  end
end
