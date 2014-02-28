require "spec_helper"

describe PusherFake::Channel::Public do
  let(:name) { "channel" }

  subject { PusherFake::Channel::Public }

  it "assigns the provided name" do
    channel = subject.new(name)

    expect(channel.name).to eq(name)
  end

  it "creates an empty connections array" do
    channel = subject.new(name)

    expect(channel.connections).to eq([])
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

    expect(connections).to have_received(:push).with(connection)
  end

  it "successfully subscribes the connection" do
    subject.add(connection)

    expect(connection).to have_received(:emit).with("pusher_internal:subscription_succeeded", {}, subject.name)
  end

  it "triggers channel occupied webhook for the first connection added" do
    subject.unstub(:connections)

    2.times { subject.add(connection) }

    expect(PusherFake::Webhook).to have_received(:trigger).with("channel_occupied", channel: name).once
  end
end

describe PusherFake::Channel, "#emit" do
  let(:data)         { stub }
  let(:name)         { "name" }
  let(:event)        { "event" }
  let(:connections)  { [connection_1, connection_2] }
  let(:connection_1) { stub(emit: nil, id: "1") }
  let(:connection_2) { stub(emit: nil, id: "2") }

  subject { PusherFake::Channel::Public.new(name) }

  before do
    subject.stubs(connections: connections)
  end

  it "emits the event for each connection in the channel" do
    subject.emit(event, data)

    expect(connection_1).to have_received(:emit).with(event, data, name)
    expect(connection_2).to have_received(:emit).with(event, data, name)
  end

  it "ignores connection if socket_id matches the connections ID" do
    subject.emit(event, data, socket_id: connection_2.id)

    expect(connection_1).to have_received(:emit).with(event, data, name)
    expect(connection_2).to have_received(:emit).never
  end
end

describe PusherFake::Channel, "#includes?" do
  let(:connection) { stub }

  subject { PusherFake::Channel::Public.new("name") }

  it "returns true if the connection is in the channel" do
    subject.stubs(connections: [connection])

    expect(subject).to be_includes(connection)
  end

  it "returns false if the connection is not in the channel" do
    subject.stubs(connections: [])

    expect(subject).to_not be_includes(connection)
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

    expect(subject.connections).to_not include(connection_1)
  end

  it "triggers channel vacated webhook when all connections are removed" do
    subject.remove(connection_1)

    expect(PusherFake::Webhook).to have_received(:trigger).never

    subject.remove(connection_2)

    expect(PusherFake::Webhook).to have_received(:trigger).with("channel_vacated", channel: name).once
  end
end

describe PusherFake::Channel::Public, "#subscription_data" do
  subject { PusherFake::Channel::Public.new("name") }

  it "returns an empty hash" do
    expect(subject.subscription_data).to eq({})
  end
end
