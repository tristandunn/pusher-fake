require "spec_helper"

describe PusherFake::Channel::Presence do
  let(:name) { "channel" }

  subject { PusherFake::Channel::Presence }

  it "inherits from private channel" do
    subject.ancestors.should include(PusherFake::Channel::Private)
  end

  it "creates an empty members hash" do
    channel = subject.new(name)
    channel.members.should == {}
  end
end

describe PusherFake::Channel::Presence, "#add" do
  let(:data)              { { auth: authentication, channel_data: "{}" } }
  let(:connection)        { stub(emit: nil) }
  let(:connections)       { stub(push: nil) }
  let(:channel_data)      { {} }
  let(:authentication)    { "auth" }
  let(:subscription_data) { { presence: { hash: {}, count: 1 } } }

  subject { PusherFake::Channel::Presence.new("name") }

  before do
    MultiJson.stubs(:load).returns(channel_data)
    subject.stubs(connections: connections, emit: nil, subscription_data: subscription_data)
  end

  it "authorizes the connection" do
    subject.stubs(authorized?: nil)
    subject.add(connection, data)
    subject.should have_received(:authorized?).with(connection, data)
  end

  it "parses the channel_data when authorized" do
    subject.stubs(authorized?: true)
    subject.add(connection, data)
    MultiJson.should have_received(:load).with(data[:channel_data], symbolize_keys: true)
  end

  it "assigns the parsed channel_data to the members hash for the current connection" do
    subject.stubs(authorized?: true)
    subject.add(connection, data)
    subject.members[connection].should == channel_data
  end

  it "notifies the channel of the new member when authorized" do
    subject.stubs(authorized?: true)
    subject.add(connection, data)
    subject.should have_received(:emit).with("pusher_internal:member_added", channel_data)
  end

  it "successfully subscribes the connection when authorized" do
    subject.stubs(authorized?: true)
    subject.add(connection, data)
    connection.should have_received(:emit).with("pusher_internal:subscription_succeeded", subscription_data, subject.name)
  end

  it "adds the connection to the channel when authorized" do
    subject.stubs(authorized?: true)
    subject.add(connection, data)
    connections.should have_received(:push).with(connection)
  end

  it "unsuccessfully subscribes the connection when not authorized" do
    subject.stubs(authorized?: false)
    subject.add(connection, data)
    connection.should have_received(:emit).with("pusher_internal:subscription_error", {}, subject.name)
  end
end

describe PusherFake::Channel::Presence, "#remove" do
  let(:connection)   { stub }
  let(:channel_data) { {} }

  subject { PusherFake::Channel::Presence.new("name") }

  before do
    subject.members[connection] = channel_data
    subject.stubs(connections: [connection], emit: nil)
  end

  it "removes the connection from the channel" do
    subject.remove(connection)
    subject.connections.should be_empty
  end

  it "removes the connection from the members hash" do
    subject.remove(connection)
    subject.members.should_not have_key(connection)
  end

  it "notifies the channel of the removed member" do
    subject.remove(connection)
    subject.should have_received(:emit).with("pusher_internal:member_removed", channel_data)
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
    subject.subscription_data.should == {
      presence: {
        hash:  { member[:user_id] => member[:user_info] },
        count: 1
      }
    }
  end

  it "handles multiple members" do
    members[stub] = other

    subject.subscription_data.should == {
      presence: {
        hash:  { member[:user_id] => member[:user_info], other[:user_id] => other[:user_info] },
        count: 2
      }
    }
  end
end
