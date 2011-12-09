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
        else
          self.channels[name] ||= Public.new(name)
        end
      end

      # Reset the channel cache.
      def reset
        self.channels = {}
      end
    end
  end
end
