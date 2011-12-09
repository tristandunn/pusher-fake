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
  let(:data)    { { channel: name, auth: "auth" } }
  let(:json)    { stub }
  let(:name)    { "channel" }
  let(:channel) { stub(add: nil) }
  let(:message) { { event: "pusher:subscribe", data: data } }

  subject { PusherFake::Connection.new(stub) }

  before do
    Yajl::Parser.stubs(:parse).returns(message)
    PusherFake::Channel.stubs(:factory).returns(channel)
  end

  it "parses the JSON data" do
    subject.process(json)
    Yajl::Parser.should have_received(:parse).with(json, symbolize_keys: true)
  end

  it "creates a channel from the event data" do
    subject.process(json)
    PusherFake::Channel.should have_received(:factory).with(name)
  end

  it "attempts to add the connection to the channel" do
    subject.process(json)
    channel.should have_received(:add).with(subject, data)
  end
end

describe PusherFake::Connection, "#process, with an unsubscribe event" do
  let(:json)    { stub }
  let(:name)    { "channel" }
  let(:channel) { stub(remove: nil) }
  let(:message) { { event: "pusher:unsubscribe", channel: name } }

  subject { PusherFake::Connection.new(stub) }

  before do
    Yajl::Parser.stubs(:parse).returns(message)
    PusherFake::Channel.stubs(:factory).returns(channel)
  end

  it "parses the JSON data" do
    subject.process(json)
    Yajl::Parser.should have_received(:parse).with(json, symbolize_keys: true)
  end

  it "creates a channel from the event data" do
    subject.process(json)
    PusherFake::Channel.should have_received(:factory).with(name)
  end

  it "removes the connection from the channel" do
    subject.process(json)
    channel.should have_received(:remove).with(subject)
  end
end

describe PusherFake::Connection, "#process, with a client event" do
  let(:data)    { {} }
  let(:json)    { stub }
  let(:name)    { "channel" }
  let(:event)   { "client-hello-world" }
  let(:channel) { stub(emit: nil, includes?: nil, is_a?: true) }
  let(:message) { { event: event, data: data, channel: name } }

  subject { PusherFake::Connection.new(stub) }

  before do
    Yajl::Parser.stubs(:parse).returns(message)
    PusherFake::Channel.stubs(:factory).returns(channel)
  end

  it "parses the JSON data" do
    subject.process(json)
    Yajl::Parser.should have_received(:parse).with(json, symbolize_keys: true)
  end

  it "creates a channel from the event data" do
    subject.process(json)
    PusherFake::Channel.should have_received(:factory).with(name)
  end

  it "ensures the channel is private" do
    subject.process(json)
    channel.should have_received(:is_a?).with(PusherFake::Channel::Private)
  end

  it "checks if the connection is in the channel" do
    subject.process(json)
    channel.should have_received(:includes?).with(subject)
  end

  it "emits the event to the channel when the connection is in the channel" do
    channel.stubs(includes?: true)
    subject.process(json)
    channel.should have_received(:emit).with(event, data)
  end

  it "does not emit the event to the channel when the channel is not private" do
    channel.stubs(includes?: true, is_a?: false)
    subject.process(json)
    channel.should have_received(:emit).never
  end

  it "does not emit the event to the channel when the connection is not in the channel" do
    channel.stubs(includes?: false)
    subject.process(json)
    channel.should have_received(:emit).never
  end
end

describe PusherFake::Connection, "#process, with an unknown event" do
  let(:data)    { {} }
  let(:json)    { stub }
  let(:name)    { "channel" }
  let(:event)   { "hello-world" }
  let(:channel) { stub(emit: nil) }
  let(:message) { { event: event, data: data, channel: name } }

  subject { PusherFake::Connection.new(stub) }

  before do
    Yajl::Parser.stubs(:parse).returns(message)
    PusherFake::Channel.stubs(:factory).returns(channel)
  end

  it "parses the JSON data" do
    subject.process(json)
    Yajl::Parser.should have_received(:parse).with(json, symbolize_keys: true)
  end

  it "creates a channel from the event data" do
    subject.process(json)
    PusherFake::Channel.should have_received(:factory).with(name)
  end

  it "does not emit the event" do
    subject.process(json)
    channel.should have_received(:emit).never
  end
end
