module PusherFake
  module Channel
    class Presence < Private
      # @return [Hash] Channel members hash.
      attr_reader :members

      # Create a new {Presence} object.
      #
      # @param [String] name The channel name.
      def initialize(name)
        super(name)

        @members = {}
      end

      # Add the connection to the channel if they are authorized.
      #
      # @param [Connection] connection The connection to add.
      # @param [Hash] options The options for the channel.
      # @option options [String] :auth The authentication string.
      # @option options [Hash] :channel_data The ID and information for the subscribed client.
      def add(connection, options = {})
        if authorized?(connection, options)
          members[connection] = Yajl::Parser.parse(options[:channel_data], symbolize_keys: true)

          emit("pusher_internal:member_added", members[connection])

          connection.emit("pusher_internal:subscription_succeeded", subscription_data, name)
          connections.push(connection)
        else
          connection.emit("pusher_internal:subscription_error", {}, name)
        end
      end

      # Removes the +connection+ from the channel and notifies the channel.
      #
      # @param [Connection] connection The connection to remove.
      def remove(connection)
        super

        emit("pusher_internal:member_removed", members.delete(connection))
      end

      # Returns a subscription hash containing presence information for
      # the channel.
      #
      # @return [Hash] Subscription hash contained presence information.
      def subscription_data
        hash = members.values.inject({}) { |result, member|
          result[member[:user_id]] = member
          result
        }

        { presence: { hash: hash, count: members.size } }
      end
    end
  end
end
