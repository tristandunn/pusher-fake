# frozen_string_literal: true

class WebhookHelper
  def self.events
    @events ||= []
  end

  def self.mutex
    @mutex ||= Mutex.new
  end
end

class WebhookEndpoint
  def self.call(environment)
    request = Rack::Request.new(environment)
    webhook = Pusher::WebHook.new(request)

    if webhook.valid?
      WebhookHelper.mutex.synchronize do
        WebhookHelper.events.concat(webhook.events)
      end
    end

    Rack::Response.new.finish
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    EventMachine::WebSocket.singleton_class.prepend(PusherFake::Server::ChainTrapHandlers)
    Thin::Server.prepend(PusherFake::Server::ChainTrapHandlers)

    thread = Thread.new do
      # Not explicitly requiring Thin::Server occasionally results in
      # Thin::Server.start not being defined.
      require "thin"
      require "thin/server"

      EventMachine.run do
        Thin::Logging.silent = true
        Thin::Server.start("0.0.0.0", 8082, WebhookEndpoint)
      end
    end

    at_exit { thread.exit }
  end
end
