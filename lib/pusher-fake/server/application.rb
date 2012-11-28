module PusherFake
  module Server
    class Application
      # Process an API request by emitting the event with data to the
      # requested channels.
      #
      # @param [Hash] environment The request environment.
      # @return [Rack::Response] A successful response.
      def self.call(environment)
        request = Rack::Request.new(environment)
        event   = MultiJson.load(request.body.read)

        event["channels"].each do |channel|
          Channel.factory(channel).emit(event["name"], event["data"])
        end

        Rack::Response.new("{}").finish
      end
    end
  end
end
