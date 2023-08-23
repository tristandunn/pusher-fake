# frozen_string_literal: true

require "spec_helper"

describe PusherFake::Channel::Presence do
  subject { described_class }

  let(:name) { "channel" }

  it "inherits from private channel" do
    expect(subject.ancestors).to include(PusherFake::Channel::Private)
  end

  it "creates an empty members hash" do
    channel = subject.new(name)

    expect(channel.members).to eq({})
  end
end

describe PusherFake::Channel::Presence, "#add" do
  subject { described_class.new(name) }

  let(:name)              { "name" }
  let(:user_id)           { "1234" }
  let(:connection)        { instance_double(PusherFake::Connection, emit: nil) }
  let(:connections)       { instance_double(Array, push: nil, length: 0) }
  let(:channel_data)      { { user_id: user_id } }
  let(:authentication)    { "auth" }
  let(:subscription_data) { { presence: { hash: {}, count: 1 } } }

  let(:data) do
    { auth:         authentication,
      channel_data: MultiJson.dump(channel_data) }
  end

  before do
    allow(PusherFake::Webhook).to receive(:trigger)
    allow(MultiJson).to receive(:load).and_return(channel_data)
    allow(subject).to receive_messages(
      connections:       connections,
      emit:              nil,
      subscription_data: subscription_data
    )
  end

  it "authorizes the connection" do
    allow(subject).to receive(:authorized?).and_return(nil)

    subject.add(connection, data)

    expect(subject).to have_received(:authorized?).with(connection, data)
  end

  it "parses the channel_data when authorized" do
    allow(subject).to receive(:authorized?).and_return(true)

    subject.add(connection, data)

    expect(MultiJson).to have_received(:load)
      .with(data[:channel_data], symbolize_keys: true)
  end

  it "assigns the channel_data to the members hash for current connection" do
    allow(subject).to receive(:authorized?).and_return(true)

    subject.add(connection, data)

    expect(subject.members[connection]).to eq(channel_data)
  end

  it "notifies the channel of the new member when authorized" do
    allow(subject).to receive(:authorized?).and_return(true)

    subject.add(connection, data)

    expect(subject).to have_received(:emit)
      .with("pusher_internal:member_added", channel_data)
  end

  it "successfully subscribes the connection when authorized" do
    allow(subject).to receive(:authorized?).and_return(true)

    subject.add(connection, data)

    expect(connection).to have_received(:emit)
      .with("pusher_internal:subscription_succeeded",
            subscription_data, subject.name)
  end

  it "adds the connection to the channel when authorized" do
    allow(subject).to receive(:authorized?).and_return(true)

    subject.add(connection, data)

    expect(connections).to have_received(:push).with(connection)
  end

  it "triggers occupied webhook for first connection added when authorized" do
    allow(subject).to receive(:authorized?).and_return(true)
    allow(subject).to receive(:connections).and_call_original

    2.times { subject.add(connection, data) }

    expect(PusherFake::Webhook).to have_received(:trigger)
      .with("channel_occupied", channel: name).once
  end

  it "triggers the member added webhook when authorized" do
    allow(subject).to receive(:authorized?).and_return(true)

    subject.add(connection, data)

    expect(PusherFake::Webhook).to have_received(:trigger)
      .with("member_added", channel: name, user_id: user_id).once
  end

  it "unsuccessfully subscribes the connection when not authorized" do
    allow(subject).to receive(:authorized?).and_return(false)

    subject.add(connection, data)

    expect(connection).to have_received(:emit)
      .with("pusher_internal:subscription_error", {}, subject.name)
  end

  it "does not trigger channel occupied webhook when not authorized" do
    allow(subject).to receive(:authorized?).and_return(false)
    allow(subject).to receive(:connections).and_call_original

    2.times { subject.add(connection, data) }

    expect(PusherFake::Webhook).not_to have_received(:trigger)
  end

  it "does not trigger the member added webhook when not authorized" do
    allow(subject).to receive(:authorized?).and_return(false)

    subject.add(connection, data)

    expect(PusherFake::Webhook).not_to have_received(:trigger)
  end
end

describe PusherFake::Channel::Presence, "#remove" do
  subject { described_class.new(name) }

  let(:name)         { "name" }
  let(:user_id)      { "1234" }
  let(:connection)   { double }
  let(:channel_data) { { user_id: user_id } }

  before do
    allow(PusherFake::Webhook).to receive(:trigger)
    allow(subject).to receive_messages(connections: [connection], emit: nil)

    subject.members[connection] = channel_data
  end

  it "removes the connection from the channel" do
    subject.remove(connection)

    expect(subject.connections).to be_empty
  end

  it "removes the connection from the members hash" do
    subject.remove(connection)

    expect(subject.members).not_to have_key(connection)
  end

  it "triggers the member removed webhook" do
    subject.remove(connection)

    expect(PusherFake::Webhook).to have_received(:trigger)
      .with("member_removed", channel: name, user_id: user_id).once
  end

  it "notifies the channel of the removed member" do
    subject.remove(connection)

    expect(subject).to have_received(:emit)
      .with("pusher_internal:member_removed", channel_data)
  end
end

describe PusherFake::Channel::Presence,
         "#remove, for an unsubscribed connection" do
  subject { described_class.new(name) }

  let(:name)         { "name" }
  let(:user_id)      { "1234" }
  let(:connection)   { double }
  let(:channel_data) { { user_id: user_id } }

  before do
    allow(subject).to receive_messages(connections: [], emit: nil, trigger: nil)
  end

  it "does not raise an error" do
    expect do
      subject.remove(connection)
    end.not_to raise_error
  end

  it "does not trigger an event" do
    subject.remove(connection)

    expect(subject).not_to have_received(:trigger)
      .with("member_removed", channel: name, user_id: user_id)
  end

  it "does not emit an event" do
    subject.remove(connection)

    expect(subject).not_to have_received(:emit)
      .with("pusher_internal:member_removed", channel_data)
  end
end

describe PusherFake::Channel::Presence, "#subscription_data" do
  subject { described_class.new("name") }

  let(:one)     { { user_id: 1, name: "Bob" } }
  let(:two)     { { user_id: 2, name: "Beau" } }
  let(:data)    { subject.subscription_data }
  let(:members) { { double => one } }

  before do
    allow(subject).to receive(:members).and_return(members)
  end

  it "returns hash with presence information" do
    expect(data).to eq(presence: {
                         hash:  { one[:user_id] => one[:user_info] },
                         count: 1
                       })
  end

  it "handles multiple members" do
    members[double] = two

    expect(data[:presence][:count]).to eq(2)
    expect(data[:presence][:hash]).to eq(
      one[:user_id] => one[:user_info], two[:user_id] => two[:user_info]
    )
  end
end
