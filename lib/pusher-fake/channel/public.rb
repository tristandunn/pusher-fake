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

      # Add the connection to the channel.
      #
      # @param [Connection] connection The connection to add.
      # @param [Hash] options The options for the channel.
      def add(connection, options = {})
        connection.emit("pusher_internal:subscription_succeeded", {}, name)
        connections.push(connection)
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
      # @return [Boolean] +true+ if the connection is in the channel, +false+ otherwise.
      def includes?(connection)
        connections.index(connection)
      end

      # Removes the +connection+ from the channel.
      #
      # @param [Connection] connection The connection to remove.
      def remove(connection)
        connections.delete(connection)
      end
    end
  end
end
