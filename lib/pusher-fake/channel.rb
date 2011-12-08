module PusherFake
  module Channel
    class << self
      # Create a channel, determing the type by the name.
      #
      # @param [Hash] options The channel options.
      # @option options [String] :channel The channel name.
      # @return [Public|Private] The channel object.
      def factory(options)
        name = options[:channel]

        if name =~ /^private-/
          Private.new(options[:channel])
        else
          Public.new(options[:channel])
        end
      end
    end
  end
end
