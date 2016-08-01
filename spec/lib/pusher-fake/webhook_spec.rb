require "spec_helper"

describe PusherFake::Webhook, ".trigger" do
  subject { described_class }

  let(:data)      { { channel: "name" } }
  let(:http)      { instance_double(EventMachine::HttpConnection, post: true) }
  let(:name)      { "channel_occupied" }
  let(:digest)    { instance_double(OpenSSL::Digest::SHA256) }
  let(:webhooks)  { ["url"] }
  let(:signature) { "signature" }

  let(:configuration) do
    instance_double(PusherFake::Configuration,
                    key:      "key",
                    secret:   "secret",
                    webhooks: webhooks)
  end

  let(:headers) do
    {
      "Content-Type"       => "application/json",
      "X-Pusher-Key"       => configuration.key,
      "X-Pusher-Signature" => signature
    }
  end

  let(:payload) do
    MultiJson.dump(events: [data.merge(name: name)], time_ms: Time.now.to_i)
  end

  before do
    allow(OpenSSL::HMAC).to receive(:hexdigest).and_return(signature)
    allow(OpenSSL::Digest::SHA256).to receive(:new).and_return(digest)
    allow(EventMachine::HttpRequest).to receive(:new).and_return(http)
    allow(PusherFake).to receive(:log)
    allow(PusherFake).to receive(:configuration).and_return(configuration)
  end

  it "generates a signature" do
    subject.trigger(name, data)

    expect(OpenSSL::HMAC).to have_received(:hexdigest)
      .with(digest, configuration.secret, payload)
  end

  it "creates a HTTP request for each webhook URL" do
    subject.trigger(name, data)

    expect(EventMachine::HttpRequest).to have_received(:new)
      .with(webhooks.first)
  end

  it "posts the payload to the webhook URL" do
    subject.trigger(name, data)

    expect(http).to have_received(:post).with(body: payload, head: headers)
  end

  it "logs sending the hook" do
    subject.trigger(name, data)

    expect(PusherFake).to have_received(:log).with("HOOK: #{payload}")
  end
end
