require "sinatra"
require "tilt/erb"

module Sinatra
  class Application
    set(:root,  proc { File.join(File.dirname(__FILE__), "application") })
    set(:views, proc { File.join(root, "views") })

    disable :logging

    get "/" do
      erb :index
    end

    post "/pusher/auth" do
      channel  = Pusher[params[:channel_name]]
      response = channel.authenticate(params[:socket_id], channel_data)

      MultiJson.dump(response)
    end

    protected

    def channel_data
      return unless params[:channel_name] =~ /^presence-/

      {
        user_id:   params[:socket_id],
        user_info: { name: "Alan Turing" }
      }
    end
  end
end
