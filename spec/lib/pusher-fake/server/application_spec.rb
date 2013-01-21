require "spec_helper"

shared_examples_for "an API request" do
  let(:hash)        { mock }
  let(:string)      { mock }
  let(:request)     { stub(path: path) }
  let(:response)    { mock }
  let(:environment) { mock }

  subject { PusherFake::Server::Application }

  before do
    response.stubs(finish: response)

    MultiJson.stubs(dump: string)
    Rack::Request.stubs(new: request)
    Rack::Response.stubs(new: response)
  end

  it "creates a request" do
    subject.call(environment)
    Rack::Request.should have_received(:new).with(environment)
  end

  it "dumps the response hash to JSON" do
    subject.call(environment)
    MultiJson.should have_received(:dump).with(hash)
  end

  it "creates a Rack response with the response JSON" do
    subject.call(environment)
    Rack::Response.should have_received(:new).with(string)
  end

  it "finishes the response" do
    subject.call(environment)
    response.should have_received(:finish).with()
  end

  it "returns the response" do
    subject.call(environment).should == response
  end
end

describe PusherFake::Server::Application, ".call, for triggering events" do
  it_should_behave_like "an API request" do
    let(:id)   { PusherFake.configuration.app_id }
    let(:path) { "/apps/#{id}/events" }

    before do
      subject.stubs(events: hash)
    end

    it "emits events" do
      subject.call(environment)
      subject.should have_received(:events).with(request)
    end
  end
end

describe PusherFake::Server::Application, ".call, for retrieving occupied channels" do
  it_should_behave_like "an API request" do
    let(:id)   { PusherFake.configuration.app_id }
    let(:path) { "/apps/#{id}/channels" }

    before do
      subject.stubs(channels: hash)
    end

    it "filters the occupied channels" do
      subject.call(environment)
      subject.should have_received(:channels).with(request)
    end
  end
end

describe PusherFake::Server::Application, ".call, raising an error" do
  let(:id)          { PusherFake.configuration.app_id }
  let(:path)        { "/apps/#{id}/channels" }
  let(:message)     { "Example error message." }
  let(:request)     { stub(path: path) }
  let(:response)    { mock }
  let(:environment) { mock }

  subject { PusherFake::Server::Application }

  before do
    subject.stubs(:channels).raises(message)

    response.stubs(finish: response)

    Rack::Request.stubs(new: request)
    Rack::Response.stubs(new: response)
  end

  it "creates a request" do
    subject.call(environment)
    Rack::Request.should have_received(:new).with(environment)
  end

  it "creates a Rack response with the error message" do
    subject.call(environment)
    Rack::Response.should have_received(:new).with(message, 400)
  end

  it "finishes the response" do
    subject.call(environment)
    response.should have_received(:finish).with()
  end

  it "returns the response" do
    subject.call(environment).should == response
  end
end

describe PusherFake::Server::Application, ".events" do
  let(:body)      { stub(read: json) }
  let(:data)      { mock }
  let(:json)      { mock }
  let(:name)      { "event-name" }
  let(:event)     { { "channels" => channels, "name" => name, "data" => data, "socket_id" => socket_id } }
  let(:request)   { stub(body: body) }
  let(:channels)  { ["channel-1", "channel-2"] }
  let(:channel_1) { stub(emit: true) }
  let(:channel_2) { stub(emit: true) }
  let(:socket_id) { stub }

  subject { PusherFake::Server::Application }

  before do
    MultiJson.stubs(load: event)
    PusherFake::Channel.stubs(:factory).with(channels[0]).returns(channel_1)
    PusherFake::Channel.stubs(:factory).with(channels[1]).returns(channel_2)
  end

  it "parses the request body as JSON" do
    subject.events(request)
    MultiJson.should have_received(:load).with(json)
  end

  it "creates channels by name" do
    subject.events(request)

    channels.each do |channel|
      PusherFake::Channel.should have_received(:factory).with(channel)
    end
  end

  it "emits the event to the channels" do
    subject.events(request)

    channel_1.should have_received(:emit).with(name, data, socket_id: socket_id)
    channel_2.should have_received(:emit).with(name, data, socket_id: socket_id)
  end
end

describe PusherFake::Server::Application, ".channels, requesting all channels" do
  let(:request)  { stub(params: {}) }
  let(:channels) { { "channel-1" => mock, "channel-2" => mock } }

  subject { PusherFake::Server::Application }

  before do
    PusherFake::Channel.stubs(channels: channels)
  end

  it "returns a hash of all the channels" do
    subject.channels(request).should == {
      channels: {
        "channel-1" => {},
        "channel-2" => {}
      }
    }
  end
end

describe PusherFake::Server::Application, ".channels, requesting channels with a filter" do
  let(:params)   { { "filter_by_prefix" => "public-" } }
  let(:request)  { stub(params: params) }
  let(:channels) { { "public-1" => mock, "presence-1" => mock } }

  subject { PusherFake::Server::Application }

  before do
    PusherFake::Channel.stubs(channels: channels)
  end

  it "returns a hash of the channels matching the filter" do
    subject.channels(request).should == { channels: { "public-1" => {} } }
  end
end

describe PusherFake::Server::Application, ".channels, requesting user count for channels with a filter" do
  let(:params)   { { "filter_by_prefix" => "presence-", "info" => "user_count" } }
  let(:request)  { stub(params: params) }
  let(:channel)  { stub(connections: [mock, mock]) }
  let(:channels) { { "public-1" => mock, "presence-1" => channel } }

  subject { PusherFake::Server::Application }

  before do
    PusherFake::Channel.stubs(channels: channels)
  end

  it "returns a hash of the channels matching the filter and include the user count" do
    subject.channels(request).should == { channels: { "presence-1" => { user_count: 2 } } }
  end
end

describe PusherFake::Server::Application, ".channels, requesting all channels with no channels occupied" do
  let(:request)  { stub(params: {}) }
  let(:channels) { nil }

  subject { PusherFake::Server::Application }

  before do
    PusherFake::Channel.stubs(channels: channels)
  end

  it "returns a hash of no channels" do
    subject.channels(request).should == { channels: {} }
  end
end

describe PusherFake::Server::Application, ".channels, requesting a user count on a non-presence channel" do
  let(:params)  { { "filter_by_prefix" => "public-", "info" => "user_count" } }
  let(:request) { stub(params: params) }

  subject { PusherFake::Server::Application }

  it "raises an error" do
    lambda {
      subject.channels(request)
    }.should raise_error(subject::CHANNEL_FILTER_ERROR)
  end
end

describe PusherFake::Server::Application, ".channel, for an occupied channel" do
  let(:name)     { "public-1" }
  let(:request)  { stub(params: {}) }
  let(:channel)  { stub(connections: [mock]) }
  let(:channels) { { name => channel } }

  subject { PusherFake::Server::Application }

  before do
    PusherFake::Channel.stubs(channels: channels)
  end

  it "returns a hash with the occupied status" do
    subject.channel(name, request).should == { occupied: true }
  end
end

describe PusherFake::Server::Application, ".channel, for an unoccupied channel" do
  let(:name)     { "public-1" }
  let(:request)  { stub(params: {}) }
  let(:channel)  { stub(connections: []) }
  let(:channels) { { name => channel } }

  subject { PusherFake::Server::Application }

  before do
    PusherFake::Channel.stubs(channels: channels)
  end

  it "returns a hash with the occupied status" do
    subject.channel(name, request).should == { occupied: false }
  end
end

describe PusherFake::Server::Application, ".channel, for an unknown channel" do
  let(:request)  { stub(params: {}) }
  let(:channels) { {} }

  subject { PusherFake::Server::Application }

  before do
    PusherFake::Channel.stubs(channels: channels)
  end

  it "returns a hash with the occupied status" do
    subject.channel("fake", request).should == { occupied: false }
  end
end

describe PusherFake::Server::Application, ".channel, request user count for a presence channel" do
  let(:name)     { "presence-1" }
  let(:params)   { { "info" => "user_count" } }
  let(:request)  { stub(params: params) }
  let(:channel)  { stub(connections: [mock, mock]) }
  let(:channels) { { name => channel } }

  subject { PusherFake::Server::Application }

  before do
    PusherFake::Channel.stubs(channels: channels)
  end

  it "returns a hash with the occupied status" do
    subject.channel(name, request).should == { occupied: true, user_count: 2 }
  end
end

describe PusherFake::Server::Application, ".channel, requesting a user count on a non-presence channel" do
  let(:params)  { { "info" => "user_count" } }
  let(:request) { stub(params: params) }

  subject { PusherFake::Server::Application }

  it "raises an error" do
    lambda {
      subject.channel("public-1", request)
    }.should raise_error(subject::CHANNEL_USER_COUNT_ERROR)
  end
end

describe PusherFake::Server::Application, ".users, for an occupied channel" do
  let(:name)     { "public-1" }
  let(:user_1)   { mock }
  let(:user_2)   { mock }
  let(:channel)  { stub(connections: [user_1, user_2]) }
  let(:channels) { { name => channel } }

  subject { PusherFake::Server::Application }

  before do
    PusherFake::Channel.stubs(channels: channels)
  end

  it "returns a hash with the occupied status" do
    subject.users(name).should == { users: [
      { id: user_1.object_id },
      { id: user_2.object_id }
    ] }
  end
end

describe PusherFake::Server::Application, ".users, for an empty channel" do
  let(:name)     { "public-1" }
  let(:channel)  { stub(connections: []) }
  let(:channels) { { name => channel } }

  subject { PusherFake::Server::Application }

  before do
    PusherFake::Channel.stubs(channels: channels)
  end

  it "returns a hash with the occupied status" do
    subject.users(name).should == { users: [] }
  end
end

describe PusherFake::Server::Application, ".users, for an unknown channel" do
  let(:channels) { {} }

  subject { PusherFake::Server::Application }

  before do
    PusherFake::Channel.stubs(channels: channels)
  end

  it "returns a hash with the occupied status" do
    subject.users("fake").should == { users: [] }
  end
end
