PusherFake.configuration.web_options.tap do |options|
  Pusher.url = "http://PUSHER_API_KEY:PUSHER_API_SECRET@#{options[:host]}:#{options[:port]}/apps/PUSHER_APP_ID"
end

Thread.new { PusherFake::Server.start }.tap do |thread|
  at_exit { thread.exit }
end

After do
  PusherFake::Channel.reset
end
