module PusherFake
  module Server
    class Application
      # Process an API request by emitting the event with data to the
      # requested channel.
      #
      # @param [Hash] environment The request environment.
      # @return [Rack::Response] A successful response.
      def self.call(environment)
        @environment = environment

        Channel.factory(channel).emit(event, data)

        Rack::Response.new.finish
      end

      # Determine the channel name from the request path.
      #
      # @return [String] The channel name.
      def self.channel
        path.match(%r{/apps/PUSHER_APP_ID/channels/(.+)/events}i)[1]
      end

      # Parse and return the event data from the request JSON.
      #
      # @return [Hash] The parsed event data.
      def self.data
        Yajl::Parser.parse(request.body.read)
      end

      # Get the environment.
      #
      # @return [Hash] The request environment.
      def self.environment
        @environment
      end

      # Get the event name from the request parameters.
      #
      # @return [String] The even name.
      def self.event
        request.params["name"]
      end

      # Get the request path from the environment.
      #
      # @return [String] The request path.
      def self.path
        environment["PATH_INFO"]
      end

      # Create a +Rack::Request+ from the environment.
      #
      # @return [Rack::Request] The request object.
      def self.request
        Rack::Request.new(environment)
      end
    end
  end
end
