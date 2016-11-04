module PusherFake
  module Channel
    # A presence channel.
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
      # Also trigger the member_removed webhook.
      #
      # @param [Connection] connection The connection to remove.
      def remove(connection)
        super

        return unless members.key?(connection)

        trigger("member_removed",
                channel: name, user_id: members[connection][:user_id])

        emit("pusher_internal:member_removed", members.delete(connection))
      end

      # Return a hash containing presence information for the channel.
      #
      # @return [Hash] Hash containing presence information.
      def subscription_data
        hash = Hash[
          members.map { |_, member| [member[:user_id], member[:user_info]] }
        ]

        { presence: { hash: hash, count: members.size } }
      end

      private

      # Store the member data for the connection and notify the channel a
      # member was added.
      #
      # Also trigger the member_added webhook.
      #
      # @param [Connection] connection Connection a subscription succeeded for.
      # @param [Hash] options The options for the channel.
      def subscription_succeeded(connection, options = {})
        member = members[connection] = MultiJson.load(
          options[:channel_data], symbolize_keys: true
        )

        emit("pusher_internal:member_added", member)

        trigger("member_added", channel: name, user_id: member[:user_id])

        super
      end
    end
  end
end
