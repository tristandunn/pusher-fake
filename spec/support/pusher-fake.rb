RSpec.configure do |config|
  config.before(:each, type: :feature) do
    PusherFake.configuration.web_options.tap do |options|
      Pusher.url = "http://PUSHER_API_KEY:PUSHER_API_SECRET@#{options[:host]}:#{options[:port]}/apps/PUSHER_APP_ID"
    end

    @thread = Thread.new { PusherFake::Server.start }
  end

  config.after(:each, type: :feature) do
    @thread.exit

    PusherFake::Channel.reset
  end
end
