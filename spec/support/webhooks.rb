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

    thread = Thread.new do
      server = Puma::Server.new(WebhookEndpoint)
      server.add_tcp_listener("0.0.0.0", 8082)
      server.run.join
    end

    at_exit { thread.exit }
  end
end
