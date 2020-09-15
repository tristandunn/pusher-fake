# frozen_string_literal: true

%w(app_id key secret).each do |setting|
  next unless Pusher.public_send(setting).nil?

  warn("Warning: Pusher.#{setting} is not set. " \
       "Should be set before including PusherFake")
end

unless defined?(PusherFake)
  warn("Warning: PusherFake is not defined. " \
       "Should be required before requiring a support file.")
end

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
Thread.new { PusherFake::Server.start }.tap do |thread|
  at_exit { Thread.kill(thread) }
end
