module PusherFake
  module Channel
    class Public
      # @return [String] The channel name.
      attr_reader :name

      # Create a new {Public} object.
      #
      # @param [String] name The channel name.
      def initialize(name)
        @name = name
      end

      # Determine if the connection is authorized for the channel.
      #
      # @return [true]
      def authorized?(connection, authentication)
        true
      end
    end
  end
end
