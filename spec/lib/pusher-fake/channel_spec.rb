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

describe PusherFake::Channel, ".factory, for a presence channel" do
  let(:name)    { "presence-channel" }
  let(:channel) { stub }

  subject { PusherFake::Channel }

  after do
    PusherFake::Channel.reset
  end

  it "caches the channel" do
    subject.factory(name).should == subject.factory(name)
  end

  it "creates a presence channel by name" do
    PusherFake::Channel::Presence.stubs(new: channel)
    subject.factory(name)
    PusherFake::Channel::Presence.should have_received(:new).with(name)
  end

  it "returns the channel instance" do
    PusherFake::Channel::Presence.stubs(new: channel)
    subject.factory(name).should == channel
  end
end

describe PusherFake::Channel, ".remove" do
  let(:channels)   { { channel_1: channel_1, channel_2: channel_2 } }
  let(:channel_1)  { stub(connections: stub(length: 0), remove: nil) }
  let(:channel_2)  { stub(connections: stub(length: 1), remove: nil) }
  let(:connection) { mock }

  subject { PusherFake::Channel }

  before do
    subject.stubs(channels: channels)
  end

  it "removes the connection from all channels" do
    subject.remove(connection)
    channel_1.should have_received(:remove).with(connection)
    channel_2.should have_received(:remove).with(connection)
  end

  it "deletes a channel with no connections remaining" do
    subject.remove(connection)
    channels.should_not have_key(:channel_1)
  end

  it "does not delete a channel with connections remaining" do
    subject.remove(connection)
    channels.should have_key(:channel_2)
  end
end

describe PusherFake::Channel, ".reset" do
  subject { PusherFake::Channel }

  it "empties the channel cache" do
    subject.reset
    subject.channels.should == {}
  end
end
