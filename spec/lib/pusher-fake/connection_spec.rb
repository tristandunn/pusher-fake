require "spec_helper"

shared_examples_for "#process" do
  let(:json) { double }

  subject { PusherFake::Connection.new(double) }

  before do
    allow(PusherFake).to receive(:log)
    allow(MultiJson).to receive(:load).and_return(message)
  end

  it "parses the JSON data" do
    subject.process(json)

    expect(MultiJson).to have_received(:load).with(json, symbolize_keys: true)
  end

  it "logs receiving the event" do
    subject.process(json)

    expect(PusherFake).to have_received(:log)
      .with("RECV #{subject.id}: #{message}")
  end
end

describe PusherFake::Connection do
  let(:socket) { double }

  subject { described_class }

  it "assigns the provided socket" do
    connection = subject.new(socket)

    expect(connection.socket).to eq(socket)
  end
end

describe PusherFake::Connection, "#emit" do
  let(:data)         { { some: "data", good: true } }
  let(:json)         { MultiJson.dump(message) }
  let(:event)        { "name" }
  let(:channel)      { "channel" }
  let(:message)      { { event: event, data: MultiJson.dump(data) } }
  let(:channel_json) { MultiJson.dump(message.merge(channel: channel)) }

  let(:socket) do
    instance_double(EventMachine::WebSocket::Connection, send: nil)
  end

  subject { described_class.new(socket) }

  before do
    allow(PusherFake).to receive(:log)
  end

  it "sends the event to the socket as JSON" do
    subject.emit(event, data)

    expect(socket).to have_received(:send).with(json)
  end

  it "sets a channel when provided" do
    subject.emit(event, data, channel)

    expect(socket).to have_received(:send).with(channel_json)
  end

  it "logs sending the event" do
    subject.emit(event, data)

    expect(PusherFake).to have_received(:log)
      .with("SEND #{subject.id}: #{message}")
  end
end

describe PusherFake::Connection, "#establish" do
  let(:socket) { double }

  subject { described_class.new(socket) }

  before do
    allow(subject).to receive(:emit)
  end

  it "emits the connection established event with the connection ID" do
    subject.establish

    expect(subject).to have_received(:emit)
      .with("pusher:connection_established",
            socket_id: subject.id, activity_timeout: 120)
  end
end

describe PusherFake::Connection, "#id" do
  let(:id)     { "123.456" }
  let(:socket) { instance_double(Object, object_id: 123_456) }

  subject { described_class.new(socket) }

  it "returns the object ID of the socket" do
    expect(subject.id).to eq(id)
  end
end

describe PusherFake::Connection, "#process, with a subscribe event" do
  it_should_behave_like "#process" do
    let(:data)    { { channel: name, auth: "auth" } }
    let(:name)    { "channel" }
    let(:message) { { event: "pusher:subscribe", data: data } }

    let(:channel) do
      instance_double(PusherFake::Channel::Presence, add: nil)
    end

    before do
      allow(PusherFake::Channel).to receive(:factory).and_return(channel)
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
end

describe PusherFake::Connection, "#process, with an unsubscribe event" do
  it_should_behave_like "#process" do
    let(:name)    { "channel" }
    let(:message) { { event: "pusher:unsubscribe", channel: name } }

    let(:channel) do
      instance_double(PusherFake::Channel::Presence, remove: nil)
    end

    before do
      allow(PusherFake::Channel).to receive(:factory).and_return(channel)
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
end

describe PusherFake::Connection, "#process, with a ping event" do
  it_should_behave_like "#process" do
    let(:message) { { event: "pusher:ping", data: {} } }

    before do
      allow(subject).to receive(:emit)
      allow(PusherFake::Channel).to receive(:factory)
    end

    it "does not create a channel" do
      subject.process(json)

      expect(PusherFake::Channel).not_to have_received(:factory)
    end

    it "emits a pong event" do
      subject.process(json)

      expect(subject).to have_received(:emit).with("pusher:pong")
    end
  end
end

describe PusherFake::Connection, "#process, with a client event" do
  it_should_behave_like "#process" do
    let(:data)    { {} }
    let(:name)    { "channel" }
    let(:event)   { "client-hello-world" }
    let(:message) { { event: event, data: data, channel: name } }

    let(:channel) do
      instance_double(PusherFake::Channel::Private,
                      emit: nil, includes?: nil, is_a?: true)
    end

    before do
      allow(subject).to receive(:trigger)
      allow(PusherFake::Channel).to receive(:factory).and_return(channel)
    end

    it "creates a channel from the event data" do
      subject.process(json)

      expect(PusherFake::Channel).to have_received(:factory).with(name)
    end

    it "ensures the channel is private" do
      subject.process(json)

      expect(channel).to have_received(:is_a?)
        .with(PusherFake::Channel::Private)
    end

    it "checks if the connection is in the channel" do
      subject.process(json)

      expect(channel).to have_received(:includes?).with(subject)
    end

    it "emits the event when the connection is in the channel" do
      allow(channel).to receive(:includes?).and_return(true)

      subject.process(json)

      expect(channel).to have_received(:emit)
        .with(event, data, socket_id: subject.id)
    end

    it "does not emit the event when the channel is not private" do
      allow(channel).to receive(:is_a?).and_return(false)
      allow(channel).to receive(:includes?).and_return(true)

      subject.process(json)

      expect(channel).not_to have_received(:emit)
    end

    it "does not emit the event when the connection is not in the channel" do
      allow(channel).to receive(:includes?).and_return(false)

      subject.process(json)

      expect(channel).not_to have_received(:emit)
    end
  end
end

describe PusherFake::Connection,
         "#process, with a client event trigger a webhook" do
  it_should_behave_like "#process" do
    let(:data)    { { example: "data" } }
    let(:name)    { "channel" }
    let(:event)   { "client-hello-world" }
    let(:user_id) { 1 }
    let(:members) { { subject => { user_id: user_id } } }
    let(:message) { { event: event, channel: name } }
    let(:options) { { channel: name, event: event, socket_id: subject.id } }

    let(:channel) do
      instance_double(PusherFake::Channel::Presence,
                      name: name, emit: nil, includes?: nil)
    end

    before do
      allow(channel).to receive(:trigger)
      allow(channel).to receive(:includes?).with(subject).and_return(true)
      allow(channel).to receive(:is_a?)
        .with(PusherFake::Channel::Private).and_return(true)
      allow(channel).to receive(:is_a?)
        .with(PusherFake::Channel::Presence).and_return(false)

      # NOTE: Hack to avoid race condition in unit tests.
      allow(Thread).to receive(:new).and_yield

      allow(PusherFake::Channel).to receive(:factory).and_return(channel)
    end

    it "triggers the client event webhook" do
      subject.process(json)

      expect(channel).to have_received(:trigger)
        .with("client_event", options).once
    end

    it "includes data in event when present" do
      message[:data] = data

      subject.process(json)

      expect(channel).to have_received(:trigger)
        .with("client_event", options.merge(data: MultiJson.dump(data))).once
    end

    it "includes user ID in event when on a presence channel" do
      allow(channel).to receive(:is_a?).and_return(true)
      allow(channel).to receive(:members).and_return(members)

      subject.process(json)

      expect(channel).to have_received(:trigger)
        .with("client_event", options.merge(user_id: user_id)).once
    end
  end
end

describe PusherFake::Connection, "#process, with an unknown event" do
  it_should_behave_like "#process" do
    let(:data)    { {} }
    let(:name)    { "channel" }
    let(:event)   { "hello-world" }
    let(:channel) { instance_double(PusherFake::Channel::Public, emit: nil) }
    let(:message) { { event: event, data: data, channel: name } }

    before do
      allow(PusherFake::Channel).to receive(:factory).and_return(channel)
    end

    it "does not create a channel" do
      subject.process(json)

      expect(PusherFake::Channel).not_to have_received(:factory)
    end

    it "does not emit the event" do
      subject.process(json)

      expect(channel).not_to have_received(:emit)
    end
  end
end
