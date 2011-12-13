Thread.new { PusherFake::Server.start }.tap do |thread|
  at_exit { thread.exit }
end

After do
  PusherFake::Channel.reset
end
