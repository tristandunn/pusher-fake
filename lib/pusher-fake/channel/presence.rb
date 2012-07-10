module PusherFake
  module Channel
    class Presence < Private
      # @return [Hash] Channel members hash.
      attr_reader :members

      # Create a new {Presence} object.
      #
      # @param [String] name The channel name.
      def initialize(name)
        super

        @members = {}
      end

      # Remove the +connection+ from the channel and notify the channel.
      #
      # @param [Connection] connection The connection to remove.
      def remove(connection)
        super

        emit("pusher_internal:member_removed", members.delete(connection))
      end

      # Return a hash containing presence information for the channel.
      #
      # @return [Hash] Hash containing presence information.
      def subscription_data
        hash = Hash[
          members.map { |_, member|
            [member[:user_id], member[:user_info]]
          }
        ]

        { presence: { hash: hash, count: members.size } }
      end

      private

      # Store the member data for the connection and notify connections a
      # member was added.
      #
      # @param [Connection] connection The connection a subscription succeeded for.
      # @param [Hash] options The options for the channel.
      def subscription_succeeded(connection, options = {})
        members[connection] = Yajl::Parser.parse(options[:channel_data], symbolize_keys: true)

        emit("pusher_internal:member_added", members[connection])

        super
      end
    end
  end
end
