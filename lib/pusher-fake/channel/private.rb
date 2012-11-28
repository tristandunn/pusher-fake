module PusherFake
  module Channel
    class Private < Public
      # Add the connection to the channel if they are authorized.
      #
      # @param [Connection] connection The connection to add.
      # @param [Hash] options The options for the channel.
      # @option options [String] :auth The authentication string.
      # @option options [Hash] :channel_data The ID and information for the subscribed client.
      def add(connection, options = {})
        if authorized?(connection, options)
          subscription_succeeded(connection, options)
        else
          connection.emit("pusher_internal:subscription_error", {}, name)
        end
      end

      # Determine if the connection is authorized for the channel.
      #
      # @param [Connection] connection The connection to authorize.
      # @param [Hash] options
      # @option options [String] :auth The authentication string.
      # @return [Boolean] +true+ if authorized, +false+ otherwise.
      def authorized?(connection, options)
        authentication_for(connection.socket.object_id, options[:channel_data]) == options[:auth]
      end

      # Generate an authentication string from the channel based on the
      # connection ID provided.
      #
      # @private
      # @param [String] id The connection ID.
      # @param [String] data Custom channel data.
      # @return [String] The authentication string.
      def authentication_for(id, data = nil)
        configuration = PusherFake.configuration
        string        = [id, name, data].compact.map(&:to_s).join(":")
        digest        = OpenSSL::Digest::SHA256.new
        signature     = OpenSSL::HMAC.hexdigest(digest, configuration.secret, string)

        "#{configuration.key}:#{signature}"
      end
    end
  end
end
