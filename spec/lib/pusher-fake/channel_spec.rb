require "spec_helper"

describe PusherFake::Channel, ".factory" do
  let(:name)    { "channel" }
  let(:channel) { stub }

  subject { PusherFake::Channel }

  after do
    PusherFake::Channel.reset
  end

  it "caches the channel" do
    subject.factory(name).should == subject.factory(name)
  end

  it "creates a public channel by name" do
    PusherFake::Channel::Public.stubs(new: channel)
    subject.factory(name)
    PusherFake::Channel::Public.should have_received(:new).with(name)
  end

  it "returns the channel instance" do
    PusherFake::Channel::Public.stubs(new: channel)
    subject.factory(name).should == channel
  end
end

describe PusherFake::Channel, ".factory, for a private channel" do
  let(:name)    { "private-channel" }
  let(:channel) { stub }

  subject { PusherFake::Channel }

  after do
    PusherFake::Channel.reset
  end

  it "caches the channel" do
    subject.factory(name).should == subject.factory(name)
  end

  it "creates a private channel by name" do
    PusherFake::Channel::Private.stubs(new: channel)
    subject.factory(name)
    PusherFake::Channel::Private.should have_received(:new).with(name)
  end

  it "returns the channel instance" do
    PusherFake::Channel::Private.stubs(new: channel)
    subject.factory(name).should == channel
  end
end

describe PusherFake::Channel, ".reset" do
  subject { PusherFake::Channel }

  it "empties the channel cache" do
    subject.reset
    subject.channels.should == {}
  end
end
