require "spec_helper"

describe PusherFake::Channel::Presence do
  let(:name) { "channel" }

  subject { PusherFake::Channel::Presence }

  it "inherits from private channel" do
    expect(subject.ancestors).to include(PusherFake::Channel::Private)
  end

  it "creates an empty members hash" do
    channel = subject.new(name)

    expect(channel.members).to eq({})
  end
end

describe PusherFake::Channel::Presence, "#add" do
  let(:data)              { { auth: authentication, channel_data: MultiJson.dump(channel_data) } }
  let(:name)              { "name" }
  let(:user_id)           { "1234" }
  let(:connection)        { stub(emit: nil) }
  let(:connections)       { stub(push: nil, length: 0) }
  let(:channel_data)      { { user_id: user_id } }
  let(:authentication)    { "auth" }
  let(:subscription_data) { { presence: { hash: {}, count: 1 } } }

  subject { PusherFake::Channel::Presence.new(name) }

  before do
    PusherFake::Webhook.stubs(:trigger)
    MultiJson.stubs(:load).returns(channel_data)
    subject.stubs(connections: connections, emit: nil, subscription_data: subscription_data)
  end

  it "authorizes the connection" do
    subject.stubs(authorized?: nil)

    subject.add(connection, data)

    expect(subject).to have_received(:authorized?).with(connection, data)
  end

  it "parses the channel_data when authorized" do
    subject.stubs(authorized?: true)

    subject.add(connection, data)

    expect(MultiJson).to have_received(:load).with(data[:channel_data], symbolize_keys: true)
  end

  it "assigns the parsed channel_data to the members hash for the current connection" do
    subject.stubs(authorized?: true)

    subject.add(connection, data)

    expect(subject.members[connection]).to eq(channel_data)
  end

  it "notifies the channel of the new member when authorized" do
    subject.stubs(authorized?: true)

    subject.add(connection, data)

    expect(subject).to have_received(:emit).with("pusher_internal:member_added", channel_data)
  end

  it "successfully subscribes the connection when authorized" do
    subject.stubs(authorized?: true)

    subject.add(connection, data)

    expect(connection).to have_received(:emit)
      .with("pusher_internal:subscription_succeeded", subscription_data, subject.name)
  end

  it "adds the connection to the channel when authorized" do
    subject.stubs(authorized?: true)

    subject.add(connection, data)

    expect(connections).to have_received(:push).with(connection)
  end

  it "triggers channel occupied webhook for the first connection added when authorized" do
    subject.unstub(:connections)
    subject.stubs(authorized?: true)

    subject.add(connection, data)

    expect(PusherFake::Webhook).to have_received(:trigger).with("channel_occupied", channel: name).once

    subject.add(connection, data)

    expect(PusherFake::Webhook).to have_received(:trigger).with("channel_occupied", channel: name).once
  end

  it "triggers the member added webhook when authorized" do
    subject.stubs(authorized?: true)

    subject.add(connection, data)

    expect(PusherFake::Webhook).to have_received(:trigger).with("member_added", channel: name, user_id: user_id).once
  end

  it "unsuccessfully subscribes the connection when not authorized" do
    subject.stubs(authorized?: false)

    subject.add(connection, data)

    expect(connection).to have_received(:emit).with("pusher_internal:subscription_error", {}, subject.name)
  end

  it "does not trigger channel occupied webhook when not authorized" do
    subject.unstub(:connections)
    subject.stubs(authorized?: false)

    subject.add(connection, data)

    expect(PusherFake::Webhook).to have_received(:trigger).never

    subject.add(connection, data)

    expect(PusherFake::Webhook).to have_received(:trigger).never
  end

  it "does not trigger the member added webhook when not authorized" do
    subject.stubs(authorized?: false)

    subject.add(connection, data)

    expect(PusherFake::Webhook).to have_received(:trigger).never
  end
end

describe PusherFake::Channel::Presence, "#remove" do
  let(:name)         { "name" }
  let(:user_id)      { "1234" }
  let(:connection)   { stub }
  let(:channel_data) { { user_id: user_id } }

  subject { PusherFake::Channel::Presence.new(name) }

  before do
    PusherFake::Webhook.stubs(:trigger)
    subject.members[connection] = channel_data
    subject.stubs(connections: [connection], emit: nil)
  end

  it "removes the connection from the channel" do
    subject.remove(connection)

    expect(subject.connections).to be_empty
  end

  it "removes the connection from the members hash" do
    subject.remove(connection)

    expect(subject.members).to_not have_key(connection)
  end

  it "triggers the member removed webhook" do
    subject.remove(connection)

    expect(PusherFake::Webhook).to have_received(:trigger).with("member_removed", channel: name, user_id: user_id).once
  end

  it "notifies the channel of the removed member" do
    subject.remove(connection)

    expect(subject).to have_received(:emit).with("pusher_internal:member_removed", channel_data)
  end
end

describe PusherFake::Channel::Presence, "#remove, for an unsubscribed connection" do
  let(:name)         { "name" }
  let(:user_id)      { "1234" }
  let(:connection)   { stub }
  let(:channel_data) { { user_id: user_id } }

  subject { PusherFake::Channel::Presence.new(name) }

  before do
    subject.stubs(connections: [], emit: nil, trigger: nil)
  end

  it "does not raise an error" do
    expect {
      subject.remove(connection)
    }.to_not raise_error
  end

  it "does not trigger an event" do
    subject.remove(connection)

    expect(PusherFake::Webhook).to have_received(:trigger).with("member_removed", channel: name, user_id: user_id).never
  end

  it "does not emit an event" do
    subject.remove(connection)

    expect(subject).to have_received(:emit).with("pusher_internal:member_removed", channel_data).never
  end
end

describe PusherFake::Channel::Presence, "#subscription_data" do
  let(:other)   { { user_id: 2, name: "Beau" } }
  let(:member)  { { user_id: 1, name: "Bob" } }
  let(:members) { { stub => member } }

  subject { PusherFake::Channel::Presence.new("name") }

  before do
    subject.stubs(members: members)
  end

  it "returns hash with presence information" do
    data = subject.subscription_data

    expect(data).to eq({
      presence: {
        hash:  { member[:user_id] => member[:user_info] },
        count: 1
      }
    })
  end

  it "handles multiple members" do
    members[stub] = other

    data = subject.subscription_data

    expect(data).to eq({
      presence: {
        hash:  { member[:user_id] => member[:user_info], other[:user_id] => other[:user_info] },
        count: 2
      }
    })
  end
end
