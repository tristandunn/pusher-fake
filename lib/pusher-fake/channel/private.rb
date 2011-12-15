module PusherFake
  module Channel
    class Private < Public
      # Determine if the connection is authorized for the channel.
      #
      # @param [Connection] connection The connection to authorize.
      # @param [Hash] options
      # @option options [String] :auth The authentication string.
      # @return [Boolean] +true+ if authorized, +false+ otherwise.
      def authorized?(connection, options)
        authentication_for(connection.socket.object_id) == options[:auth]
      end

      # Generate an authentication string from the channel based on the
      # connection ID provided.
      #
      # @private
      # @param [String] id The connection ID.
      # @return [String] The authentication string.
      def authentication_for(id)
        configuration = PusherFake.configuration
        string        = [id, name].map(&:to_s).join(":")
        signature     = HMAC::SHA256.hexdigest(configuration.secret, string)

        "#{configuration.key}:#{signature}"
      end
    end
  end
end
