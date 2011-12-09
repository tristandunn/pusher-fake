require "spec_helper"

describe PusherFake::Channel::Private do
  subject { PusherFake::Channel::Private }

  it "inherits from public channel" do
    subject.ancestors.should include(PusherFake::Channel::Public)
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
    HMAC::SHA256.stubs(:hexdigest).returns(signature)
  end

  it "generates a signature" do
    subject.authentication_for(id)
    HMAC::SHA256.should have_received(:hexdigest).with(configuration.secret, string)
  end

  it "returns the authentication string" do
    subject.authentication_for(id).should == "#{configuration.key}:#{signature}"
  end
end

describe PusherFake::Channel::Private, "#authorized?" do
  let(:data)           { { auth: authentication } }
  let(:name)           { "private-channel" }
  let(:socket)         { stub }
  let(:connection)     { stub(socket: socket) }
  let(:authentication) { "authentication" }

  subject { PusherFake::Channel::Private.new(name) }

  before do
    subject.stubs(:authentication_for)
  end

  it "generates authentication for the connection socket ID" do
    subject.authorized?(connection, data)
    subject.should have_received(:authentication_for).with(socket.object_id)
  end

  it "returns true if the authentication matches" do
    subject.stubs(:authentication_for).returns(authentication)
    subject.authorized?(connection, data).should be_true
  end

  it "returns false if the authentication matches" do
    subject.stubs(:authentication_for).returns("")
    subject.authorized?(connection, data).should be_false
  end
end
