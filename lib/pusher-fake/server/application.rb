module PusherFake
  module Server
    # The fake web application.
    class Application
      CHANNEL_FILTER_ERROR = "user_count may only be requested for presence " \
                             "channels - please supply filter_by_prefix " \
                             "begining with presence-".freeze

      CHANNEL_USER_COUNT_ERROR = "Cannot retrieve the user count unless the " \
                                 "channel is a presence channel".freeze

      PRESENCE_PREFIX_MATCHER = /\Apresence-/

      REQUEST_PATHS = {
        %r{\A/apps/:id/batch_events\z}           => :batch_events,
        %r{\A/apps/:id/events\z}                 => :events,
        %r{\A/apps/:id/channels\z}               => :channels,
        %r{\A/apps/:id/channels/([^/]+)\z}       => :channel,
        %r{\A/apps/:id/channels/([^/]+)/users\z} => :users
      }.freeze

      # Process an API request.
      #
      # @param [Hash] environment The request environment.
      # @return [Rack::Response] A successful response.
      def self.call(environment)
        request  = Rack::Request.new(environment)
        response = response_for(request)

        Rack::Response.new(MultiJson.dump(response)).finish
      rescue StandardError => error
        Rack::Response.new(error.message, 400).finish
      end

      # Emit batch events with data to the requested channel(s).
      #
      # @param [Rack::Request] request The HTTP request.
      # @return [Hash] An empty hash.
      def self.batch_events(request)
        batch = MultiJson.load(request.body.read)["batch"]
        batch.each do |event|
          send_event(event)
        end

        {}
      end

      # Emit an event with data to the requested channel(s).
      #
      # @param [Rack::Request] request The HTTP request.
      # @return [Hash] An empty hash.
      def self.events(request)
        event = MultiJson.load(request.body.read)

        send_event(event)

        {}
      end

      # Return a hash of channel information.
      #
      # Occupied status is always included. A user count may be requested for
      # presence channels.
      #
      # @param [String] name The channel name.
      # @param [Rack::Request] request The HTTP request.
      # @return [Hash] A hash of channel information.
      def self.channel(name, request)
        count = request.params["info"].to_s.split(",").include?("user_count")

        if count && name !~ PRESENCE_PREFIX_MATCHER
          raise CHANNEL_USER_COUNT_ERROR
        end

        channel     = PusherFake::Channel.channels[name]
        connections = channel ? channel.connections : []

        result = { occupied: connections.any? }
        result[:user_count] = connections.size if count
        result
      end

      # Returns a hash of occupied channels, optionally filtering with a
      # prefix. When filtering to presence chanenls, the user count maybe also
      # be requested.
      #
      # @param [Rack::Request] request The HTTP request.
      # @return [Hash] A hash of occupied channels.
      #
      # rubocop:disable Metrics/AbcSize
      def self.channels(request)
        count  = request.params["info"].to_s.split(",").include?("user_count")
        prefix = request.params["filter_by_prefix"].to_s

        raise CHANNEL_FILTER_ERROR if count && prefix !~ PRESENCE_PREFIX_MATCHER

        PusherFake::Channel
          .channels
          .each_with_object(channels: {}) do |(name, channel), result|
            next unless name.start_with?(prefix)

            channels = result[:channels].merge!(name => {})
            channels[name][:user_count] = channel.connections.size if count
          end
      end
      # rubocop:enable Metrics/AbcSize

      # Attempt to provide a response for the provided request.
      #
      # @param [Rack::Request] request The HTTP request.
      # @return [Hash] A response hash.
      def self.response_for(request)
        id = PusherFake.configuration.app_id.to_s

        REQUEST_PATHS.each do |path, method|
          matcher = Regexp.new(path.to_s.sub(":id", id))
          matches = matcher.match(request.path)

          next if matches.nil?

          arguments = [matches[1], request].compact

          return public_send(method, *arguments)
        end

        raise "Unknown path: #{request.path}"
      end

      # Returns a hash of the IDs for the users in the channel.
      #
      # @param [String] name The channel name.
      # @return [Hash] A hash of user IDs.
      def self.users(name, _request = nil)
        channels = PusherFake::Channel.channels || {}
        channel  = channels[name]

        if channel
          users = channel.connections.map do |connection|
            { id: connection.id }
          end
        end

        { users: users || [] }
      end

      private_class_method

      # Emit an event with data to the requested channel(s).
      #
      # @param [Hash] event The raw event JSON.
      #
      # rubocop:disable Style/RescueModifier
      def self.send_event(event)
        data     = MultiJson.load(event["data"]) rescue event["data"]
        channels = Array(event["channels"] || event["channel"])
        channels.each do |channel_name|
          channel = Channel.factory(channel_name)
          channel.emit(event["name"], data, socket_id: event["socket_id"])
        end
      end
      # rubocop:enable Style/RescueModifier
    end
  end
end
