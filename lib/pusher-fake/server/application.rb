module PusherFake
  module Server
    class Application
      def self.call(environment)
        @environment = environment

        Channel.factory(channel).emit(event, data)

        Rack::Response.new.finish
      end

      def self.channel
        path.match(%r{/apps/PUSHER_APP_ID/channels/(.+)/events}i)[1]
      end

      def self.data
        Yajl::Parser.parse(request.body.read)
      end

      def self.environment
        @environment
      end

      def self.event
        request.params["name"]
      end

      def self.path
        environment["PATH_INFO"]
      end

      def self.request
        Rack::Request.new(environment)
      end
    end
  end
end
