# frozen_string_literal: true

module PusherFake
  # Channel creation and management.
  module Channel
    autoload :Public,   "pusher-fake/channel/public"
    autoload :Private,  "pusher-fake/channel/private"
    autoload :Presence, "pusher-fake/channel/presence"

    # Prefix for private channels.
    PRIVATE_CHANNEL_PREFIX = "private-"

    # Prefix for presence channels.
    PRESENCE_CHANNEL_PREFIX = "presence-"

    class << self
      # @return [Hash] Cache of existing channels.
      attr_writer :channels

      # @return [Hash] Cache of existing channels.
      def channels
        @channels ||= {}
      end

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
        return if channels.nil?

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

      # Determine the channel class to use based on the channel name.
      #
      # @param [String] name The name of the channel.
      # @return [Class] The class to use for the channel.
      def class_for(name)
        if name.start_with?(PRIVATE_CHANNEL_PREFIX)
          Private
        elsif name.start_with?(PRESENCE_CHANNEL_PREFIX)
          Presence
        else
          Public
        end
      end
    end
  end
end
