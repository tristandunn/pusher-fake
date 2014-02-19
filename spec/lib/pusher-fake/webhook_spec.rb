require "spec_helper"

describe PusherFake::Webhook, ".trigger" do
  subject { PusherFake::Webhook }

  let(:data)          { { channel: "name" } }
  let(:http)          { stub(post: true) }
  let(:name)          { "channel_occupied" }
  let(:payload)       { MultiJson.dump({ events: [data.merge(name: name)], time_ms: Time.now.to_i }) }
  let(:webhooks)      { ["url"] }
  let(:signature)     { "signature" }
  let(:configuration) { stub(key: "key", secret: "secret", webhooks: webhooks) }

  before do
    OpenSSL::HMAC.stubs(hexdigest: signature)
    EventMachine::HttpRequest.stubs(new: http)
    PusherFake.stubs(configuration: configuration)
  end

  it "generates a signature" do
    subject.trigger(name, data)

    expect(OpenSSL::HMAC).to have_received(:hexdigest)
      .with(kind_of(OpenSSL::Digest::SHA256), configuration.secret, payload)
  end

  it "creates a HTTP request for each webhook URL" do
    subject.trigger(name, data)

    expect(EventMachine::HttpRequest).to have_received(:new).with(webhooks.first)
  end

  it "posts the payload to the webhook URL" do
    subject.trigger(name, data)

    expect(http).to have_received(:post).with(
      body: payload,
      head: {
        "Content-Type"       => "application/json",
        "X-Pusher-Key"       => configuration.key,
        "X-Pusher-Signature" => signature
      }
    )
  end
end
