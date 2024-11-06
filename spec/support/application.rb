# frozen_string_literal: true

require "rack"

module PusherFake
  module Testing
    class Application
      def call(env)
        request = Rack::Request.new(env)

        case request.path
        when "/"                then index
        when "/pusher/auth"     then authenticate(request.params)
        when %r{\A/javascripts} then asset(request.path)
        else
          [404, {}, []]
        end
      end

      private

      def asset(path)
        headers = { "content-type" => "text/javascript" }
        root    = File.join(File.dirname(__FILE__), "application")
        body    = File.read(File.join(root, "public", path))

        [200, headers, [body]]
      end

      def authenticate(params)
        channel  = Pusher[params["channel_name"]]
        response = channel.authenticate(params["socket_id"], channel_data(params))
        headers  = { "Content-Type" => "application/json" }

        [200, headers, [MultiJson.dump(response)]]
      end

      def channel_data(params)
        return unless /^presence-/.match?(params["channel_name"])

        {
          user_id:   params["socket_id"],
          user_info: { name: "Alan Turing" }
        }
      end

      def index
        headers  = { "content-type" => "text/html" }
        root     = File.join(File.dirname(__FILE__), "application")
        template = File.read(File.join(root, "views", "index.erb"))
        erb      = ERB.new(template)
        body     = erb.result(binding)

        [200, headers, [body]]
      end
    end
  end
end
