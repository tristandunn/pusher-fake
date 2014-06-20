# Use the same API key and secret as the live version.
PusherFake.configure do |configuration|
  configuration.app_id = Pusher.app_id
  configuration.key    = Pusher.key
  configuration.secret = Pusher.secret
end

# Set the host and port to the fake web server.
PusherFake.configuration.web_options.tap do |options|
  Pusher.host = options[:host]
  Pusher.port = options[:port]
end

# Start the fake socket and web servers.
fork { PusherFake::Server.start }.tap do |id|
  at_exit { Process.kill("KILL", id) }
end
