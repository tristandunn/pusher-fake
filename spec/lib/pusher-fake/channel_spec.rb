require "spec_helper"

describe PusherFake::Channel, ".factory" do
  let(:name)    { "channel" }
  let(:channel) { stub }

  subject { PusherFake::Channel }

  before do
    PusherFake::Channel::Public.stubs(new: channel)
  end

  after do
    PusherFake::Channel.reset
  end

  it "caches the channel" do
    PusherFake::Channel::Public.unstub(:new)
    subject.factory(name).should == subject.factory(name)
  end

  it "creates a public channel by name" do
    subject.factory(name)
    PusherFake::Channel::Public.should have_received(:new).with(name)
  end

  it "returns the channel instance" do
    subject.factory(name).should == channel
  end
end

describe PusherFake::Channel, ".factory, for a private channel" do
  let(:name)    { "private-channel" }
  let(:channel) { stub }

  subject { PusherFake::Channel }

  before do
    PusherFake::Channel::Private.stubs(new: channel)
  end

  after do
    PusherFake::Channel.reset
  end

  it "caches the channel" do
    PusherFake::Channel::Private.unstub(:new)
    subject.factory(name).should == subject.factory(name)
  end

  it "creates a private channel by name" do
    subject.factory(name)
    PusherFake::Channel::Private.should have_received(:new).with(name)
  end

  it "returns the channel instance" do
    subject.factory(name).should == channel
  end
end

describe PusherFake::Channel, ".factory, for a presence channel" do
  let(:name)    { "presence-channel" }
  let(:channel) { stub }

  subject { PusherFake::Channel }

  before do
    PusherFake::Channel::Presence.stubs(new: channel)
  end

  after do
    PusherFake::Channel.reset
  end

  it "caches the channel" do
    PusherFake::Channel::Presence.unstub(:new)
    subject.factory(name).should == subject.factory(name)
  end

  it "creates a presence channel by name" do
    subject.factory(name)
    PusherFake::Channel::Presence.should have_received(:new).with(name)
  end

  it "returns the channel instance" do
    subject.factory(name).should == channel
  end
end

describe PusherFake::Channel, ".remove" do
  let(:channels)   { { channel_1: channel_1, channel_2: channel_2 } }
  let(:channel_1)  { stub(connections: stub(empty?: true), remove: nil) }
  let(:channel_2)  { stub(connections: stub(empty?: false), remove: nil) }
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

  it "handles channels not being defined" do
    subject.stubs(channels: nil)
    subject.remove(connection)
  end
end

describe PusherFake::Channel, ".reset" do
  subject { PusherFake::Channel }

  it "empties the channel cache" do
    subject.factory("example")
    subject.reset
    subject.channels.should == {}
  end
end
