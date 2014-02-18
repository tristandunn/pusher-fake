$events = []

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
    Thread.current[:ready] = true
  end
end.tap do |thread|
  at_exit { thread.exit }

  # Wait for the webhook endpoint server to start.
  Timeout::timeout(5) do
    sleep(0.05) until thread[:ready]
  end
end

PusherFake.configuration.webhooks = ["http://localhost:8082"]
