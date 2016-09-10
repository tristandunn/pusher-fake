require "spec_helper"

describe PusherFake::Channel::Public do
  subject { described_class }

  let(:name) { "channel" }

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
  subject { PusherFake::Channel::Public.new(name) }

  let(:name)        { "name" }
  let(:connection)  { instance_double(PusherFake::Connection, emit: nil) }
  let(:connections) { instance_double(Array, push: nil, length: 0) }

  before do
    allow(PusherFake::Webhook).to receive(:trigger)
    allow(subject).to receive(:connections).and_return(connections)
  end

  it "adds the connection" do
    subject.add(connection)

    expect(connections).to have_received(:push).with(connection)
  end

  it "successfully subscribes the connection" do
    subject.add(connection)

    expect(connection).to have_received(:emit)
      .with("pusher_internal:subscription_succeeded", {}, subject.name)
  end

  it "triggers channel occupied webhook for the first connection added" do
    allow(subject).to receive(:connections).and_call_original

    2.times { subject.add(connection) }

    expect(PusherFake::Webhook).to have_received(:trigger)
      .with("channel_occupied", channel: name).once
  end
end

describe PusherFake::Channel, "#emit" do
  subject { PusherFake::Channel::Public.new(name) }

  let(:data)        { double }
  let(:name)        { "name" }
  let(:event)       { "event" }
  let(:connections) { [connection_1, connection_2] }

  let(:connection_1) do
    instance_double(PusherFake::Connection, emit: nil, id: "1")
  end

  let(:connection_2) do
    instance_double(PusherFake::Connection, emit: nil, id: "2")
  end

  before do
    allow(subject).to receive(:connections).and_return(connections)
  end

  it "emits the event for each connection in the channel" do
    subject.emit(event, data)

    expect(connection_1).to have_received(:emit).with(event, data, name)
    expect(connection_2).to have_received(:emit).with(event, data, name)
  end

  it "ignores connection if socket_id matches the connections ID" do
    subject.emit(event, data, socket_id: connection_2.id)

    expect(connection_1).to have_received(:emit).with(event, data, name)
    expect(connection_2).not_to have_received(:emit)
  end
end

describe PusherFake::Channel, "#includes?" do
  subject { PusherFake::Channel::Public.new("name") }

  let(:connection) { double }

  it "returns true if the connection is in the channel" do
    allow(subject).to receive(:connections).and_return([connection])

    expect(subject).to be_includes(connection)
  end

  it "returns false if the connection is not in the channel" do
    allow(subject).to receive(:connections).and_return([])

    expect(subject).not_to be_includes(connection)
  end
end

describe PusherFake::Channel, "#remove" do
  subject { PusherFake::Channel::Public.new(name) }

  let(:name)         { "name" }
  let(:connection_1) { double }
  let(:connection_2) { double }

  before do
    allow(PusherFake::Webhook).to receive(:trigger)
    allow(subject).to receive(:connections)
      .and_return([connection_1, connection_2])
  end

  it "removes the connection from the channel" do
    subject.remove(connection_1)

    expect(subject.connections).not_to include(connection_1)
  end

  it "triggers channel vacated webhook when all connections are removed" do
    subject.remove(connection_1)

    expect(PusherFake::Webhook).not_to have_received(:trigger)

    subject.remove(connection_2)

    expect(PusherFake::Webhook).to have_received(:trigger)
      .with("channel_vacated", channel: name).once
  end
end

describe PusherFake::Channel::Public, "#subscription_data" do
  subject { described_class.new("name") }

  it "returns an empty hash" do
    expect(subject.subscription_data).to eq({})
  end
end
