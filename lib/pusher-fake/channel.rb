module PusherFake
  module Channel
    class << self
      PRIVATE_CHANNEL_MATCHER  = /^private-/.freeze
      PRESENCE_CHANNEL_MATCHER = /^presence-/.freeze

      attr_accessor :channels

      # Create a channel, determining the type by the name.
      #
      # @param [String] name The channel name.
      # @return [Public|Private] The channel object.
      def factory(name)
        self.channels       ||= {}
        self.channels[name] ||= class_for(name).new(name)
      end

      # Remove a connection from all channels.
      #
      # Also deletes the channel if it is empty.
      #
      # @param [Connection] connection The connection to remove.
      def remove(connection)
        channels.each do |name, channel|
          channel.remove(connection)

          if channels[name].connections.empty?
            channels.delete(name)
          end
        end
      end

      # Reset the channel cache.
      def reset
        self.channels = {}
      end

      private

      def class_for(name)
        if name =~ PRIVATE_CHANNEL_MATCHER
          Private
        elsif name =~ PRESENCE_CHANNEL_MATCHER
          Presence
        else
          Public
        end
      end
    end
  end
end
