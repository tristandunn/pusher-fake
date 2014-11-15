require "spec_helper"

describe PusherFake::Channel::Private do
  subject { PusherFake::Channel::Private }

  it "inherits from public channel" do
    expect(subject.ancestors).to include(PusherFake::Channel::Public)
  end
end

describe PusherFake::Channel::Private, "#add" do
  let(:data)           { { auth: authentication } }
  let(:name)           { "name" }
  let(:connection)     { double(:connection, emit: nil) }
  let(:connections)    { double(:connections, push: nil, length: 0) }
  let(:authentication) { "auth" }

  subject { PusherFake::Channel::Private.new(name) }

  before do
    allow(PusherFake::Webhook).to receive(:trigger)
    allow(subject).to receive(:connections).and_return(connections)
  end

  it "authorizes the connection" do
    allow(subject).to receive(:authorized?).and_return(nil)

    subject.add(connection, data)

    expect(subject).to have_received(:authorized?).with(connection, data)
  end

  it "adds the connection to the channel when authorized" do
    allow(subject).to receive(:authorized?).and_return(true)

    subject.add(connection, data)

    expect(connections).to have_received(:push).with(connection)
  end

  it "successfully subscribes the connection when authorized" do
    allow(subject).to receive(:authorized?).and_return(true)

    subject.add(connection, data)

    expect(connection).to have_received(:emit).with("pusher_internal:subscription_succeeded", {}, subject.name)
  end

  it "triggers channel occupied webhook for the first connection added when authorized" do
    allow(subject).to receive(:authorized?).and_return(true)
    allow(subject).to receive(:connections).and_call_original

    2.times { subject.add(connection, data) }

    expect(PusherFake::Webhook).to have_received(:trigger).with("channel_occupied", channel: name).once
  end

  it "unsuccessfully subscribes the connection when not authorized" do
    allow(subject).to receive(:authorized?).and_return(false)

    subject.add(connection, data)

    expect(connection).to have_received(:emit).with("pusher_internal:subscription_error", {}, subject.name)
  end

  it "does not trigger channel occupied webhook when not authorized" do
    allow(subject).to receive(:authorized?).and_return(false)
    allow(subject).to receive(:connections).and_call_original

    2.times { subject.add(connection, data) }

    expect(PusherFake::Webhook).to_not have_received(:trigger)
  end
end

describe PusherFake::Channel::Private, "#authentication_for" do
  let(:id)            { "1234" }
  let(:name)          { "private-channel" }
  let(:digest)        { double(:digest) }
  let(:string)        { [id, name].join(":") }
  let(:signature)     { "signature" }
  let(:configuration) { double(:configuration, key: "key", secret: "secret") }

  subject { PusherFake::Channel::Private.new(name) }

  before do
    allow(PusherFake).to receive(:configuration).and_return(configuration)
    allow(OpenSSL::HMAC).to receive(:hexdigest).and_return(signature)
    allow(OpenSSL::Digest::SHA256).to receive(:new).and_return(digest)
  end

  it "generates a signature" do
    subject.authentication_for(id)

    expect(OpenSSL::HMAC).to have_received(:hexdigest)
      .with(digest, configuration.secret, string)
  end

  it "returns the authentication string" do
    string = subject.authentication_for(id)

    expect(string).to eq("#{configuration.key}:#{signature}")
  end
end

describe PusherFake::Channel::Private, "#authentication_for, with channel data" do
  let(:id)            { "1234" }
  let(:name)          { "private-channel" }
  let(:digest)        { double(:digest) }
  let(:string)        { [id, name, channel_data].join(":") }
  let(:signature)     { "signature" }
  let(:channel_data)  { "{}" }
  let(:configuration) { double(:configuration, key: "key", secret: "secret") }

  subject { PusherFake::Channel::Private.new(name) }

  before do
    allow(PusherFake).to receive(:configuration).and_return(configuration)
    allow(OpenSSL::HMAC).to receive(:hexdigest).and_return(signature)
    allow(OpenSSL::Digest::SHA256).to receive(:new).and_return(digest)
  end

  it "generates a signature" do
    subject.authentication_for(id, channel_data)

    expect(OpenSSL::HMAC).to have_received(:hexdigest)
      .with(digest, configuration.secret, string)
  end

  it "returns the authentication string" do
    string = subject.authentication_for(id, channel_data)

    expect(string).to eq("#{configuration.key}:#{signature}")
  end
end

describe PusherFake::Channel::Private, "#authorized?" do
  let(:data)           { { auth: authentication, channel_data: channel_data } }
  let(:name)           { "private-channel" }
  let(:connection)     { double(:connection, id: "1") }
  let(:channel_data)   { "{}" }
  let(:authentication) { "authentication" }

  subject { PusherFake::Channel::Private.new(name) }

  before do
    allow(subject).to receive(:authentication_for)
  end

  it "generates authentication for the connection ID" do
    subject.authorized?(connection, data)

    expect(subject).to have_received(:authentication_for).with(connection.id, channel_data)
  end

  it "returns true if the authentication matches" do
    allow(subject).to receive(:authentication_for).and_return(authentication)

    expect(subject).to be_authorized(connection, data)
  end

  it "returns false if the authentication matches" do
    allow(subject).to receive(:authentication_for).and_return("")

    expect(subject).to_not be_authorized(connection, data)
  end
end
