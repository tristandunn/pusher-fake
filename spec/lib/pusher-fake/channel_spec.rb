require "spec_helper"

describe PusherFake::Channel, ".factory" do
  let(:name)    { "channel" }
  let(:channel) { stub }
  let(:options) { { channel: name } }

  subject { PusherFake::Channel }

  before do
    PusherFake::Channel::Public.stubs(:new).returns(channel)
  end

  it "creates a public channel by name" do
    subject.factory(options)
    PusherFake::Channel::Public.should have_received(:new).with(name)
  end

  it "returns the channel instance" do
    subject.factory(options).should == channel
  end
end

describe PusherFake::Channel, ".factory, for a private channel" do
  let(:name)    { "private-channel" }
  let(:channel) { stub }
  let(:options) { { channel: name } }

  subject { PusherFake::Channel }

  before do
    PusherFake::Channel::Private.stubs(:new).returns(channel)
  end

  it "creates a private channel by name" do
    subject.factory(options)
    PusherFake::Channel::Private.should have_received(:new).with(name)
  end

  it "returns the channel instance" do
    subject.factory(options).should == channel
  end
end
