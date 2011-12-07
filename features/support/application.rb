require "sinatra"

class Sinatra::Application
  set :root,          Proc.new { File.join(File.dirname(__FILE__), "application") }
  set :views,         Proc.new { File.join(root, "views") }
  set :public_folder, Proc.new { File.join(root, "public") }

  disable :logging

  get "/" do
    erb :index
  end
end
