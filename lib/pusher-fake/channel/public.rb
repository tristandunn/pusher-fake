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
        subscription_succeeded(connection, options)
      end

      # Emit an event to the channel.
      #
      # @param [String] event The event name.
      # @param [Hash] data The event data.
      def emit(event, data, options = {})
        connections.each do |connection|
          unless connection.id == options[:socket_id]
            connection.emit(event, data, name)
          end
        end
      end

      # Determine if the +connection+ is in the channel.
      #
      # @param [Connection] connection The connection.
      # @return [Boolean] +true+ if the connection is in the channel, +false+ otherwise.
      def includes?(connection)
        connections.index(connection)
      end

      # Remove the +connection+ from the channel.
      #
      # If it is the last connection, trigger the channel_vacated webhook.
      #
      # @param [Connection] connection The connection to remove.
      def remove(connection)
        connections.delete(connection)

        if connections.empty?
          trigger("channel_vacated", channel: name)
        end
      end

      # Return subscription data for the channel.
      #
      # @abstract
      # @return [Hash] Subscription data for the channel.
      def subscription_data
        {}
      end

      def trigger(name, data = {})
        PusherFake::Webhook.trigger(name, data)
      end

      private

      # Notify the +connection+ of the successful subscription and add the
      # connection to the channel.
      #
      # If it is the first connection, trigger the channel_occupied webhook.
      #
      # @param [Connection] connection The connection a subscription succeeded for.
      # @param [Hash] options The options for the channel.
      def subscription_succeeded(connection, options = {})
        connection.emit("pusher_internal:subscription_succeeded", subscription_data, name)
        connections.push(connection)

        if connections.length == 1
          trigger("channel_occupied", channel: name)
        end
      end
    end
  end
end
