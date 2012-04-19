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

      # Removes the +connection+ from the channel and notifies the channel.
      #
      # @param [Connection] connection The connection to remove.
      def remove(connection)
        super

        emit("pusher_internal:member_removed", members.delete(connection))
      end

      # Returns a hash containing presence information for the channel.
      #
      # @return [Hash] Hash containing presence information.
      def subscription_data
        hash = Hash[
          members.map { |_, member|
#            [member[:user_id], member]
             [member[:user_id], member[:user_info]]
          }
        ]
        { presence: { hash: hash, count: members.size, ids: members.map { |_,m| m[:user_id] } } }
      end

      private

      def subscription_succeeded(connection, options = {})
        members[connection] = Yajl::Parser.parse(options[:channel_data], symbolize_keys: true)
        emit("pusher_internal:member_added", members[connection])

        super
      end
    end
  end
end
