RSpec.configure do |config|
  config.before(:each) do
    $events = []
  end
end

Thread.new do
  # Not explicitly requiring Thin::Server occasionally results in
  # Thin::Server.start not being defined.
  require "thin"
  require "thin/server"

  class WebhookEndpoint
    def self.call(environment)
      request = Rack::Request.new(environment)
      webhook = Pusher::WebHook.new(request)

      if webhook.valid?
        $events.concat(webhook.events)
      end

      Rack::Response.new.finish
    end
  end

  EventMachine.run do
    Thin::Logging.silent = true
    Thin::Server.start("0.0.0.0", 8082, WebhookEndpoint)
  end
end.tap do |thread|
  at_exit { thread.exit }
end

PusherFake.configuration.webhooks = ["http://127.0.0.1:8082"]
