module PusherFake
  module Channel
    class << self
      attr_accessor :channels

      # Create a channel, determing the type by the name.
      #
      # @param [String] name The channel name.
      # @return [Public|Private] The channel object.
      def factory(name)
        self.channels ||= {}

        if name =~ /^private-/
          self.channels[name] ||= Private.new(name)
        elsif name =~ /^presence-/
          self.channels[name] ||= Presence.new(name)
        else
          self.channels[name] ||= Public.new(name)
        end
      end

      # Remove a connection from all channels.
      #
      # Also deletes the channel if it is empty.
      #
      # @param [Connection] connection The connection to remove.
      def remove(connection)
        channels.each do |name, channel|
          channel.remove(connection)

          if channels[name].connections.length == 0
            channels.delete(name)
          end
        end
      end

      # Reset the channel cache.
      def reset
        self.channels = {}
      end
    end
  end
end
