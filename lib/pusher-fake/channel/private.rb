module PusherFake
  module Channel
    class Private < Public
      # Determine if the connection is authorized for the channel.
      #
      # @return [Boolean] +true+ if authorized, +false+ otherwise.
      def authorized?(connection, authentication)
        authentication_for(connection.socket.object_id) == authentication
      end

      # @private
      def authentication_for(id)
        configuration = PusherFake.configuration
        string        = [id, name].map(&:to_s).join(":")
        signature     = HMAC::SHA256.hexdigest(configuration.secret, string)

        "#{configuration.key}:#{signature}"
      end
    end
  end
end
