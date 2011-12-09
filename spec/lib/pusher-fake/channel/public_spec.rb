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
  let(:data)           { { auth: authentication } }
  let(:connection)     { stub(emit: nil) }
  let(:connections)    { stub(push: nil) }
  let(:authentication) { "auth" }

  subject { PusherFake::Channel::Public.new("name") }

  before do
    subject.stubs(authorized?: nil, connections: connections)
  end

  it "authorizes the connection" do
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

describe PusherFake::Channel, "#authorized?" do
  let(:data)           { { auth: authentication } }
  let(:connection)     { stub }
  let(:authentication) { "auth" }

  subject { PusherFake::Channel::Public.new("name") }

  it "returns true" do
    subject.should be_authorized(connection, data)
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
  let(:connection) { stub }

  subject { PusherFake::Channel::Public.new("name") }

  before do
    subject.stubs(connections: [connection])
  end

  it "removes the connection from the channel" do
    subject.remove(connection)
    subject.connections.should be_empty
  end
end
