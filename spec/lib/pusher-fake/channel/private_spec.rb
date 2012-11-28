require "spec_helper"

describe PusherFake::Channel::Private do
  subject { PusherFake::Channel::Private }

  it "inherits from public channel" do
    subject.ancestors.should include(PusherFake::Channel::Public)
  end
end

describe PusherFake::Channel::Private, "#add" do
  let(:data)           { { auth: authentication } }
  let(:connection)     { stub(emit: nil) }
  let(:connections)    { stub(push: nil) }
  let(:authentication) { "auth" }

  subject { PusherFake::Channel::Private.new("name") }

  before do
    subject.stubs(connections: connections)
  end

  it "authorizes the connection" do
    subject.stubs(authorized?: nil)
    subject.add(connection, data)
    subject.should have_received(:authorized?).with(connection, data)
  end

  it "adds the connection to the channel when authorized" do
    subject.stubs(authorized?: true)
    subject.add(connection, data)
    connections.should have_received(:push).with(connection)
  end

  it "successfully subscribes the connection when authorized" do
    subject.stubs(authorized?: true)
    subject.add(connection, data)
    connection.should have_received(:emit).with("pusher_internal:subscription_succeeded", {}, subject.name)
  end

  it "unsuccessfully subscribes the connection when not authorized" do
    subject.stubs(authorized?: false)
    subject.add(connection, data)
    connection.should have_received(:emit).with("pusher_internal:subscription_error", {}, subject.name)
  end
end

describe PusherFake::Channel::Private, "#authentication_for" do
  let(:id)            { "1234" }
  let(:name)          { "private-channel" }
  let(:string)        { [id, name].join(":") }
  let(:signature)     { "signature" }
  let(:configuration) { stub(key: "key", secret: "secret") }

  subject { PusherFake::Channel::Private.new(name) }

  before do
    PusherFake.stubs(configuration: configuration)
    OpenSSL::HMAC.stubs(hexdigest: signature)
  end

  it "generates a signature" do
    subject.authentication_for(id)
    OpenSSL::HMAC.should have_received(:hexdigest).with(kind_of(OpenSSL::Digest::SHA256), configuration.secret, string)
  end

  it "returns the authentication string" do
    subject.authentication_for(id).should == "#{configuration.key}:#{signature}"
  end
end

describe PusherFake::Channel::Private, "#authentication_for, with channel data" do
  let(:id)            { "1234" }
  let(:name)          { "private-channel" }
  let(:string)        { [id, name, channel_data].join(":") }
  let(:signature)     { "signature" }
  let(:channel_data)  { "{}" }
  let(:configuration) { stub(key: "key", secret: "secret") }

  subject { PusherFake::Channel::Private.new(name) }

  before do
    PusherFake.stubs(configuration: configuration)
    OpenSSL::HMAC.stubs(hexdigest: signature)
  end

  it "generates a signature" do
    subject.authentication_for(id, channel_data)
    OpenSSL::HMAC.should have_received(:hexdigest).with(kind_of(OpenSSL::Digest::SHA256), configuration.secret, string)
  end

  it "returns the authentication string" do
    subject.authentication_for(id, channel_data).should == "#{configuration.key}:#{signature}"
  end
end

describe PusherFake::Channel::Private, "#authorized?" do
  let(:data)           { { auth: authentication, channel_data: channel_data } }
  let(:name)           { "private-channel" }
  let(:socket)         { stub }
  let(:connection)     { stub(socket: socket) }
  let(:channel_data)   { "{}" }
  let(:authentication) { "authentication" }

  subject { PusherFake::Channel::Private.new(name) }

  before do
    subject.stubs(:authentication_for)
  end

  it "generates authentication for the connection socket ID" do
    subject.authorized?(connection, data)
    subject.should have_received(:authentication_for).with(socket.object_id, channel_data)
  end

  it "returns true if the authentication matches" do
    subject.stubs(authentication_for: authentication)
    subject.authorized?(connection, data).should be_true
  end

  it "returns false if the authentication matches" do
    subject.stubs(authentication_for: "")
    subject.authorized?(connection, data).should be_false
  end
end
