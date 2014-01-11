Pusher.url = "http://PUSHER_API_KEY:PUSHER_API_SECRET@localhost:8081/apps/PUSHER_APP_ID"

Thread.new { PusherFake::Server.start }.tap do |thread|
  at_exit { thread.exit }
end

After do
  PusherFake::Channel.reset
end
