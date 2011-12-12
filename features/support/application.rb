require "pusher"
require "sinatra"

Pusher.url = "http://PUSHER_API_KEY:PUSHER_API_SECRET@localhost:8081/apps/PUSHER_APP_ID"

class Sinatra::Application
  set :root,          Proc.new { File.join(File.dirname(__FILE__), "application") }
  set :views,         Proc.new { File.join(root, "views") }
  set :public_folder, Proc.new { File.join(root, "public") }

  disable :logging

  get "/" do
    erb :index
  end

  post "/pusher/auth" do
    Pusher[params[:channel_name]].authenticate(params[:socket_id]).to_json
  end
end
