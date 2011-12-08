require "spec_helper"

describe PusherFake::Connection do
  let(:socket) { stub }

  subject { PusherFake::Connection }

  it "assigns the provided socket" do
    connection = subject.new(socket)
    connection.socket.should == socket
  end
end

describe PusherFake::Connection, "#emit" do
  let(:data)         { { some: "data", good: true } }
  let(:json)         { Yajl::Encoder.encode(message) }
  let(:event)        { "name" }
  let(:socket)       { stub(:send) }
  let(:channel)      { "channel" }
  let(:message)      { { event: event, data: data } }
  let(:channel_json) { Yajl::Encoder.encode(message.merge(channel: channel)) }

  subject { PusherFake::Connection.new(socket) }

  it "sends the event to the socket as JSON" do
    subject.emit(event, data)
    socket.should have_received(:send).with(json)
  end

  it "sets a channel when provided" do
    subject.emit(event, data, channel)
    socket.should have_received(:send).with(channel_json)
  end
end

describe PusherFake::Connection, "#establish" do
  let(:socket) { stub }

  subject { PusherFake::Connection.new(socket) }

  before do
    subject.stubs(:emit)
  end

  it "emits the connection established event with the socket ID" do
    subject.establish
    subject.should have_received(:emit).with("pusher:connection_established", socket_id: socket.object_id)
  end
end

describe PusherFake::Connection, "#process, with a subscribe event" do
  let(:json)    { stub }
  let(:channel) { "channel" }
  let(:message) { { event: "pusher:subscribe", data: { channel: channel } } }

  subject { PusherFake::Connection.new(stub) }

  before do
    subject.stubs(:emit)
    Yajl::Parser.stubs(:parse).returns(message)
  end

  it "parses the JSON data" do
    subject.process(json)
    Yajl::Parser.should have_received(:parse).with(json, symbolize_keys: true)
  end

  it "emits a subscription succeeded event for the channel" do
    subject.process(json)
    subject.should have_received(:emit).with("pusher_internal:subscription_succeeded", {}, channel)
  end
end
