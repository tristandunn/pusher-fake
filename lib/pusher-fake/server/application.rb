module PusherFake
  module Server
    class Application
      CHANNEL_FILTER_ERROR = "user_count may only be requested for presence channels - " +
                               "please supply filter_by_prefix begining with presence-".freeze

      CHANNEL_USER_COUNT_ERROR = "Cannot retrieve the user count unless the channel is a presence channel".freeze

      PRESENCE_PREFIX_MATCHER = /\Apresence-/.freeze

      # Process an API request.
      #
      # @param [Hash] environment The request environment.
      # @return [Rack::Response] A successful response.
      def self.call(environment)
        id       = PusherFake.configuration.app_id
        request  = Rack::Request.new(environment)
        response = case request.path
                   when %r{\A/apps/#{id}/events\Z}
                     events(request)
                   when %r{\A/apps/#{id}/channels\Z}
                     channels(request)
                   when %r{\A/apps/#{id}/channels/([^/]+)\Z}
                     channel($1, request)
                   when %r{\A/apps/#{id}/channels/([^/]+)/users\Z}
                     users($1)
                   else
                     raise "Unknown path: #{request.path}"
                   end

        Rack::Response.new(MultiJson.dump(response)).finish
      rescue => error
        Rack::Response.new(error.message, 400).finish
      end

      # Emit an event with data to the requested channel(s).
      #
      # @param [Rack::Request] request The HTTP request.
      # @return [Hash] An empty hash.
      def self.events(request)
        event = MultiJson.load(request.body.read)
        event["channels"].each do |channel|
          Channel.factory(channel).emit(event["name"], event["data"], socket_id: event["socket_id"])
        end

        {}
      end

      # Return a hash of channel information.
      #
      # Occupied status is always included. A user count may be requested for
      # presence channels.
      #
      # @param [String] name The channel name.
      # @params [Rack::Request] request The HTTP request.
      # @return [Hash] A hash of channel information.
      def self.channel(name, request)
        info = request.params["info"].to_s.split(",")

        if info.include?("user_count") && name !~ PRESENCE_PREFIX_MATCHER
          raise CHANNEL_USER_COUNT_ERROR
        end

        channels = PusherFake::Channel.channels || {}
        channel  = channels[name]

        {}.tap do |result|
          result[:occupied]   = !channel.nil? && channel.connections.length > 0
          result[:user_count] = channel.connections.length if channel && info.include?("user_count")
        end
      end

      # Returns a hash of occupied channels, optionally filtering with a prefix.
      #
      # When filtering to presence chanenls, the user count maybe also be requested.
      #
      # @param [Rack::Request] request The HTTP request.
      # @return [Hash] A hash of occupied channels.
      def self.channels(request)
        info   = request.params["info"].to_s.split(",")
        prefix = request.params["filter_by_prefix"].to_s

        if info.include?("user_count") && prefix !~ PRESENCE_PREFIX_MATCHER
          raise CHANNEL_FILTER_ERROR
        end

        filter   = Regexp.new(%r{\A#{prefix}})
        channels = PusherFake::Channel.channels || {}
        channels.inject(channels: {}) do |result, (name, channel)|
          unless filter && name !~ filter
            channels = result[:channels]
            channels[name] = {}
            channels[name][:user_count] = channel.connections.length if info.include?("user_count")
          end

          result
        end
      end

      # Returns a hash of the IDs for the users in the channel.
      #
      # @param [String] name The channel name.
      # @return [Hash] A hash of user IDs.
      def self.users(name)
        channels = PusherFake::Channel.channels || {}
        channel  = channels[name]

        if channel
          users = channel.connections.map do |connection|
            { id: connection.id }
          end
        end

        { users: users || [] }
      end
    end
  end
end
