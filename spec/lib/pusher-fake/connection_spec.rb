require "spec_helper"

shared_examples_for "#process" do
  let(:json) { stub }

  subject { PusherFake::Connection.new(stub) }

  before do
    PusherFake.stubs(:log)
    MultiJson.stubs(load: message)
  end

  it "parses the JSON data" do
    subject.process(json)

    expect(MultiJson).to have_received(:load).with(json, symbolize_keys: true)
  end

  it "logs receiving the event" do
    subject.process(json)

    expect(PusherFake).to have_received(:log).with("RECV #{subject.id}: #{message}")
  end
end

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
  let(:message)      { { event: event, data: MultiJson.dump(data) } }
  let(:channel_json) { MultiJson.dump(message.merge(channel: channel)) }

  subject { PusherFake::Connection.new(socket) }

  before do
    PusherFake.stubs(:log)
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

    expect(PusherFake).to have_received(:log).with("SEND #{subject.id}: #{message}")
  end
end

describe PusherFake::Connection, "#establish" do
  let(:socket) { stub }

  subject { PusherFake::Connection.new(socket) }

  before do
    subject.stubs(:emit)
  end

  it "emits the connection established event with the connection ID" do
    subject.establish

    expect(subject).to have_received(:emit)
      .with("pusher:connection_established", socket_id: subject.id, activity_timeout: 120)
  end
end

describe PusherFake::Connection, "#id" do
  let(:id)     { socket.object_id.to_s }
  let(:socket) { stub }

  subject { PusherFake::Connection.new(socket) }

  it "returns the object ID of the socket" do
    expect(subject.id).to eq(id)
  end
end

describe PusherFake::Connection, "#process, with a subscribe event" do
  it_should_behave_like "#process" do
    let(:data)    { { channel: name, auth: "auth" } }
    let(:name)    { "channel" }
    let(:channel) { stub(add: nil) }
    let(:message) { { event: "pusher:subscribe", data: data } }

    before do
      PusherFake::Channel.stubs(factory: channel)
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
    let(:channel) { stub(remove: nil) }
    let(:message) { { event: "pusher:unsubscribe", channel: name } }

    before do
      PusherFake::Channel.stubs(factory: channel)
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
      subject.stubs(:emit)
    end

    it "does not create a channel" do
      subject.process(json)

      expect(PusherFake::Channel).to have_received(:factory).never
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
    let(:channel) { stub(emit: nil, includes?: nil, is_a?: true) }
    let(:message) { { event: event, data: data, channel: name } }

    before do
      subject.stubs(:trigger)
      PusherFake::Channel.stubs(factory: channel)
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

      expect(channel).to have_received(:emit).with(event, data, socket_id: subject.id)
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
end

describe PusherFake::Connection, "#process, with a client event trigger a webhook" do
  it_should_behave_like "#process" do
    let(:data)    { { example: "data" } }
    let(:name)    { "channel" }
    let(:event)   { "client-hello-world" }
    let(:user_id) { 1 }
    let(:channel) { stub(name: name, emit: nil, includes?: nil) }
    let(:message) { { event: event, channel: name } }
    let(:options) { { channel: name, event: event, socket_id: subject.id } }

    before do
      channel.stubs(:trigger)
      channel.stubs(:includes?).with(subject).returns(true)
      channel.stubs(:is_a?).with(PusherFake::Channel::Private).returns(true)
      channel.stubs(:is_a?).with(PusherFake::Channel::Presence).returns(false)

      # NOTE: Hack to avoid race condition in unit tests.
      Thread.stubs(:new).yields

      PusherFake::Channel.stubs(factory: channel)
    end

    it "triggers the client event webhook" do
      subject.process(json)

      expect(channel).to have_received(:trigger)
        .with("client_event", options).once
    end

    it "includes data in event when present" do
      message[:data] = data

      subject.process(json)

      expect(channel).to have_received(:trigger).
        with("client_event", options.merge(data: MultiJson.dump(data))).once
    end

    it "includes user ID in event when on a presence channel" do
      channel.stubs(:is_a?).with(PusherFake::Channel::Presence).returns(true)
      channel.stubs(members: { subject => { user_id: user_id } })

      subject.process(json)

      expect(channel).to have_received(:trigger).
        with("client_event", options.merge(user_id: user_id)).once
    end
  end
end

describe PusherFake::Connection, "#process, with an unknown event" do
  it_should_behave_like "#process" do
    let(:data)    { {} }
    let(:name)    { "channel" }
    let(:event)   { "hello-world" }
    let(:channel) { stub(emit: nil) }
    let(:message) { { event: event, data: data, channel: name } }

    before do
      PusherFake::Channel.stubs(factory: channel)
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
end
