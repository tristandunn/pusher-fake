require "spec_helper"

describe PusherFake::Channel::Public do
  let(:name) { "channel" }

  subject { PusherFake::Channel::Public }

  it "assigns the provided name" do
    channel = subject.new(name)
    channel.name.should == name
  end

  it "creates an empty connections array" do
    channel = subject.new(name)
    channel.connections.should == []
  end
end

describe PusherFake::Channel, "#add" do
  let(:name)        { "name" }
  let(:connection)  { stub(emit: nil) }
  let(:connections) { stub(push: nil, length: 0) }

  subject { PusherFake::Channel::Public.new(name) }

  before do
    PusherFake::Webhook.stubs(:trigger)
    subject.stubs(connections: connections)
  end

  it "adds the connection" do
    subject.add(connection)
    connections.should have_received(:push).with(connection)
  end

  it "successfully subscribes the connection" do
    subject.add(connection)
    connection.should have_received(:emit).with("pusher_internal:subscription_succeeded", {}, subject.name)
  end

  it "triggers channel occupied webhook for the first connection added" do
    subject.unstub(:connections)

    subject.add(connection)
    PusherFake::Webhook.should have_received(:trigger).with("channel_occupied", channel: name).once
    subject.add(connection)
    PusherFake::Webhook.should have_received(:trigger).with("channel_occupied", channel: name).once
  end
end

describe PusherFake::Channel, "#emit" do
  let(:data)         { stub }
  let(:name)         { "name" }
  let(:event)        { "event" }
  let(:connections)  { [connection_1, connection_2] }
  let(:connection_1) { stub(emit: nil) }
  let(:connection_2) { stub(emit: nil) }

  subject { PusherFake::Channel::Public.new(name) }

  before do
    subject.stubs(connections: connections)
  end

  it "emits the event for each connection in the channel" do
    subject.emit(event, data)
    connection_1.should have_received(:emit).with(event, data, name)
    connection_2.should have_received(:emit).with(event, data, name)
  end
end

describe PusherFake::Channel, "#includes?" do
  let(:connection) { stub }

  subject { PusherFake::Channel::Public.new("name") }

  it "returns true if the connection is in the channel" do
    subject.stubs(connections: [connection])
    subject.includes?(connection).should be_true
  end

  it "returns false if the connection is not in the channel" do
    subject.stubs(connections: [])
    subject.includes?(connection).should be_false
  end
end

describe PusherFake::Channel, "#remove" do
  let(:name)         { "name" }
  let(:connection_1) { stub  }
  let(:connection_2) { stub }

  subject { PusherFake::Channel::Public.new(name) }

  before do
    subject.stubs(connections: [connection_1, connection_2])
    PusherFake::Webhook.stubs(:trigger)
  end

  it "removes the connection from the channel" do
    subject.remove(connection_1)
    subject.connections.should_not include(connection_1)
  end

  it "triggers channel vacated webhook when all connections are removed" do
    subject.remove(connection_1)
    PusherFake::Webhook.should have_received(:trigger).never
    subject.remove(connection_2)
    PusherFake::Webhook.should have_received(:trigger).with("channel_vacated", channel: name).once
  end
end

describe PusherFake::Channel::Public, "#subscription_data" do
  subject { PusherFake::Channel::Public.new("name") }

  it "returns an empty hash" do
    subject.subscription_data.should == {}
  end
end
