module PusherFake
  module Server
    class Application
      CHANNEL_FILTER_ERROR = "user_count may only be requested for presence channels - " +
                               "please supply filter_by_prefix begining with presence-".freeze

      # Process an API request.
      #
      # @param [Hash] environment The request environment.
      # @return [Rack::Response] A successful response.
      def self.call(environment)
        id       = PusherFake.configuration.app_id
        request  = Rack::Request.new(environment)
        response = case request.path
                   when %r{/apps/#{id}/events}
                     events(request)
                   when %r{/apps/#{id}/channels}
                     channels(request)
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

      # Returns a hash of occupied channels, optionally filtering with a prefix.
      #
      # When filtering to presence chanenls, the user count maybe also be requested.
      #
      # @param [Rack::Request] request The HTTP request.
      # @return [Hash] A hash of occupied channels.
      def self.channels(request)
        info   = request.params["info"].to_s.split(",")
        prefix = request.params["filter_by_prefix"].to_s

        if info.include?("user_count") && prefix != "presence-"
          raise CHANNEL_FILTER_ERROR
        end

        filter   = Regexp.new(%r{\A#{prefix}})
        channels = PusherFake::Channel.channels || {}
        channels.inject({ channels: {} }) do |result, (name, channel)|
          unless filter && name !~ filter
            channels = result[:channels]
            channels[name] = {}
            channels[name][:user_count] = channel.connections.length if info.include?("user_count")
          end

          result
        end
      end
    end
  end
end
