require "spec_helper"

describe PusherFake::Connection do
  let(:socket) { stub }

  subject { PusherFake::Connection }

  it "assigns the provided socket" do
    connection = subject.new(socket)

    expect(connection.socket).to eq(socket)
  end
end

describe PusherFake::Connection, "#emit" do
  let(:data)         { { some: "data", good: true } }
  let(:json)         { MultiJson.dump(message) }
  let(:event)        { "name" }
  let(:socket)       { stub(:send) }
  let(:channel)      { "channel" }
  let(:message)      { { event: event, data: data } }
  let(:channel_json) { MultiJson.dump(message.merge(channel: channel)) }

  subject { PusherFake::Connection.new(socket) }

  it "sends the event to the socket as JSON" do
    subject.emit(event, data)

    expect(socket).to have_received(:send).with(json)
  end

  it "sets a channel when provided" do
    subject.emit(event, data, channel)

    expect(socket).to have_received(:send).with(channel_json)
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

    expect(subject).to have_received(:emit)
      .with("pusher:connection_established", socket_id: socket.object_id, activity_timeout: 120)
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
    MultiJson.stubs(load: message)
    PusherFake::Channel.stubs(factory: channel)
  end

  it "parses the JSON data" do
    subject.process(json)

    expect(MultiJson).to have_received(:load).with(json, symbolize_keys: true)
  end

  it "creates a channel from the event data" do
    subject.process(json)

    expect(PusherFake::Channel).to have_received(:factory).with(name)
  end

  it "attempts to add the connection to the channel" do
    subject.process(json)

    expect(channel).to have_received(:add).with(subject, data)
  end
end

describe PusherFake::Connection, "#process, with an unsubscribe event" do
  let(:json)    { stub }
  let(:name)    { "channel" }
  let(:channel) { stub(remove: nil) }
  let(:message) { { event: "pusher:unsubscribe", channel: name } }

  subject { PusherFake::Connection.new(stub) }

  before do
    MultiJson.stubs(load: message)
    PusherFake::Channel.stubs(factory: channel)
  end

  it "parses the JSON data" do
    subject.process(json)

    expect(MultiJson).to have_received(:load).with(json, symbolize_keys: true)
  end

  it "creates a channel from the event data" do
    subject.process(json)

    expect(PusherFake::Channel).to have_received(:factory).with(name)
  end

  it "removes the connection from the channel" do
    subject.process(json)

    expect(channel).to have_received(:remove).with(subject)
  end
end

describe PusherFake::Connection, "#process, with a ping event" do
  let(:json)    { stub }
  let(:message) { { event: "pusher:ping", data: {} } }

  subject { PusherFake::Connection.new(stub) }

  before do
    MultiJson.stubs(load: message)
    PusherFake::Channel.stubs(:factory)
    subject.stubs(:emit)
  end

  it "parses the JSON data" do
    subject.process(json)

    expect(MultiJson).to have_received(:load).with(json, symbolize_keys: true)
  end

  it "creates no channels" do
    subject.process(json)

    expect(PusherFake::Channel).to have_received(:factory).never
  end

  it "emits a pong event" do
    subject.process(json)

    expect(subject).to have_received(:emit).with("pusher:pong")
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
    MultiJson.stubs(load: message)
    PusherFake::Channel.stubs(factory: channel)
  end

  it "parses the JSON data" do
    subject.process(json)

    expect(MultiJson).to have_received(:load).with(json, symbolize_keys: true)
  end

  it "creates a channel from the event data" do
    subject.process(json)

    expect(PusherFake::Channel).to have_received(:factory).with(name)
  end

  it "ensures the channel is private" do
    subject.process(json)

    expect(channel).to have_received(:is_a?).with(PusherFake::Channel::Private)
  end

  it "checks if the connection is in the channel" do
    subject.process(json)

    expect(channel).to have_received(:includes?).with(subject)
  end

  it "emits the event to the channel when the connection is in the channel" do
    channel.stubs(includes?: true)

    subject.process(json)

    expect(channel).to have_received(:emit).with(event, data, socket_id: subject.socket.object_id)
  end

  it "does not emit the event to the channel when the channel is not private" do
    channel.stubs(includes?: true, is_a?: false)

    subject.process(json)

    expect(channel).to have_received(:emit).never
  end

  it "does not emit the event to the channel when the connection is not in the channel" do
    channel.stubs(includes?: false)

    subject.process(json)

    expect(channel).to have_received(:emit).never
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
    MultiJson.stubs(load: message)
    PusherFake::Channel.stubs(factory: channel)
  end

  it "parses the JSON data" do
    subject.process(json)

    expect(MultiJson).to have_received(:load).with(json, symbolize_keys: true)
  end

  it "creates a channel from the event data" do
    subject.process(json)

    expect(PusherFake::Channel).to have_received(:factory).with(name)
  end

  it "does not emit the event" do
    subject.process(json)

    expect(channel).to have_received(:emit).never
  end
end
