# frozen_string_literal: true

require "spec_helper"

shared_examples_for "an API request" do
  subject { PusherFake::Server::Application }

  let(:hash)        { double }
  let(:string)      { double }
  let(:request)     { instance_double(Rack::Request, path: path) }
  let(:response)    { double }
  let(:environment) { double }

  before do
    allow(response).to receive(:finish).and_return(response)

    allow(MultiJson).to receive(:dump).and_return(string)
    allow(Rack::Request).to receive(:new).and_return(request)
    allow(Rack::Response).to receive(:new).and_return(response)
  end

  it "creates a request" do
    subject.call(environment)

    expect(Rack::Request).to have_received(:new).with(environment)
  end

  it "dumps the response hash to JSON" do
    subject.call(environment)

    expect(MultiJson).to have_received(:dump).with(hash)
  end

  it "creates a Rack response with the response JSON" do
    subject.call(environment)

    expect(Rack::Response).to have_received(:new).with(string)
  end

  it "finishes the response" do
    subject.call(environment)

    expect(response).to have_received(:finish).with(no_args)
  end

  it "returns the response" do
    result = subject.call(environment)

    expect(result).to eq(response)
  end
end

describe PusherFake::Server::Application, ".call, with a numeric ID" do
  it_behaves_like "an API request" do
    let(:id)   { Time.now.to_i }
    let(:path) { "/apps/#{id}/events" }

    before do
      PusherFake.configuration.app_id = id

      allow(subject).to receive(:events).and_return(hash)
    end

    after do
      PusherFake.configuration.app_id = "PUSHER_APP_ID"
    end
  end
end

describe PusherFake::Server::Application, ".call, for triggering events" do
  it_behaves_like "an API request" do
    let(:id)   { PusherFake.configuration.app_id }
    let(:path) { "/apps/#{id}/events" }

    before do
      allow(subject).to receive(:events).and_return(hash)
    end

    it "emits events" do
      subject.call(environment)

      expect(subject).to have_received(:events).with(request)
    end
  end
end

describe PusherFake::Server::Application,
         ".call, for triggering batch events" do
  it_behaves_like "an API request" do
    let(:id)   { PusherFake.configuration.app_id }
    let(:path) { "/apps/#{id}/batch_events" }

    before do
      allow(subject).to receive(:batch_events).and_return(hash)
    end

    it "emits batch events" do
      subject.call(environment)

      expect(subject).to have_received(:batch_events).with(request)
    end
  end
end

describe PusherFake::Server::Application,
         ".call, retrieving occupied channels" do
  it_behaves_like "an API request" do
    let(:id)   { PusherFake.configuration.app_id }
    let(:path) { "/apps/#{id}/channels" }

    before do
      allow(subject).to receive(:channels).and_return(hash)
    end

    it "filters the occupied channels" do
      subject.call(environment)

      expect(subject).to have_received(:channels).with(request)
    end
  end
end

describe PusherFake::Server::Application, ".call, with unknown path" do
  subject { described_class }

  let(:path)        { "/apps/fake/events" }
  let(:request)     { instance_double(Rack::Request, path: path) }
  let(:message)     { "Unknown path: #{path}" }
  let(:response)    { double }
  let(:environment) { double }

  before do
    allow(response).to receive(:finish).and_return(response)

    allow(Rack::Request).to receive(:new).and_return(request)
    allow(Rack::Response).to receive(:new).and_return(response)
  end

  it "creates a request" do
    subject.call(environment)

    expect(Rack::Request).to have_received(:new).with(environment)
  end

  it "creates a Rack response with the error message" do
    subject.call(environment)

    expect(Rack::Response).to have_received(:new).with(message, 400)
  end

  it "finishes the response" do
    subject.call(environment)

    expect(response).to have_received(:finish).with(no_args)
  end

  it "returns the response" do
    result = subject.call(environment)

    expect(result).to eq(response)
  end
end

describe PusherFake::Server::Application, ".call, raising an error" do
  subject { described_class }

  let(:id)          { PusherFake.configuration.app_id }
  let(:path)        { "/apps/#{id}/channels" }
  let(:message)     { "Example error message." }
  let(:request)     { instance_double(Rack::Request, path: path) }
  let(:response)    { double }
  let(:environment) { double }

  before do
    allow(subject).to receive(:channels).and_raise(message)

    allow(response).to receive(:finish).and_return(response)

    allow(Rack::Request).to receive(:new).and_return(request)
    allow(Rack::Response).to receive(:new).and_return(response)
  end

  it "creates a request" do
    subject.call(environment)

    expect(Rack::Request).to have_received(:new).with(environment)
  end

  it "creates a Rack response with the error message" do
    subject.call(environment)

    expect(Rack::Response).to have_received(:new).with(message, 400)
  end

  it "finishes the response" do
    subject.call(environment)

    expect(response).to have_received(:finish).with(no_args)
  end

  it "returns the response" do
    result = subject.call(environment)

    expect(result).to eq(response)
  end
end

describe PusherFake::Server::Application, ".events" do
  subject { described_class }

  let(:body)       { instance_double(StringIO, read: event_json) }
  let(:data)       { { "example" => "data" } }
  let(:name)       { "event-name" }
  let(:request)    { instance_double(Rack::Request, body: body) }
  let(:channels)   { %w(channel-1 channel-2) }
  let(:channel_1)  { instance_double(PusherFake::Channel::Public, emit: true) }
  let(:channel_2)  { instance_double(PusherFake::Channel::Public, emit: true) }
  let(:data_json)  { data.to_json }
  let(:socket_id)  { double }
  let(:event_json) { double }

  let(:event) do
    {
      "channels"  => channels,
      "name"      => name,
      "data"      => data_json,
      "socket_id" => socket_id
    }
  end

  before do
    allow(MultiJson).to receive(:load).with(event_json).and_return(event)
    allow(MultiJson).to receive(:load).with(data_json).and_return(data)
    allow(PusherFake::Channel).to receive(:factory)
      .with(channels[0]).and_return(channel_1)
    allow(PusherFake::Channel).to receive(:factory)
      .with(channels[1]).and_return(channel_2)
  end

  it "parses the request body as JSON" do
    subject.events(request)

    expect(MultiJson).to have_received(:load).with(event_json)
  end

  it "parses the event data as JSON" do
    subject.events(request)

    expect(MultiJson).to have_received(:load).with(data_json)
  end

  it "handles invalid JSON for event data" do
    event["data"] = data = "fake"

    allow(MultiJson).to receive(:load)
      .with(data).and_raise(MultiJson::LoadError)

    expect { subject.events(request) }.not_to raise_error
  end

  it "creates channels by name" do
    subject.events(request)

    channels.each do |channel|
      expect(PusherFake::Channel).to have_received(:factory).with(channel)
    end
  end

  it "emits the event to the channels" do
    subject.events(request)

    expect(channel_1).to have_received(:emit)
      .with(name, data, socket_id: socket_id)
    expect(channel_2).to have_received(:emit)
      .with(name, data, socket_id: socket_id)
  end
end

describe PusherFake::Server::Application, ".batch_events" do
  subject { described_class }

  let(:body)       { instance_double(StringIO, read: event_json) }
  let(:data)       { { "example" => "data" } }
  let(:name)       { "event-name" }
  let(:request)    { instance_double(Rack::Request, body: body) }
  let(:channels)   { %w(channel-1 channel-2) }
  let(:channel_1)  { instance_double(PusherFake::Channel::Public, emit: true) }
  let(:channel_2)  { instance_double(PusherFake::Channel::Public, emit: true) }
  let(:data_json)  { data.to_json }
  let(:socket_id)  { double }
  let(:event_json) { double }

  let(:batch) do
    {
      "batch" => [{
        "channels"  => channels,
        "name"      => name,
        "data"      => data_json,
        "socket_id" => socket_id
      }]
    }
  end

  before do
    allow(MultiJson).to receive(:load).with(event_json).and_return(batch)
    allow(MultiJson).to receive(:load).with(data_json).and_return(data)
    allow(PusherFake::Channel).to receive(:factory)
      .with(channels[0]).and_return(channel_1)
    allow(PusherFake::Channel).to receive(:factory)
      .with(channels[1]).and_return(channel_2)
  end

  it "parses the request body as JSON" do
    subject.batch_events(request)

    expect(MultiJson).to have_received(:load).with(event_json)
  end

  it "parses the event data as JSON" do
    subject.batch_events(request)

    expect(MultiJson).to have_received(:load).with(data_json)
  end

  it "handles invalid JSON for event data" do
    batch["batch"].first["data"] = data = "fake"

    allow(MultiJson).to receive(:load)
      .with(data).and_raise(MultiJson::LoadError)

    expect { subject.batch_events(request) }.not_to raise_error
  end

  it "creates channels by name" do
    subject.batch_events(request)

    channels.each do |channel|
      expect(PusherFake::Channel).to have_received(:factory).with(channel)
    end
  end

  it "emits the event to the channels" do
    subject.batch_events(request)

    expect(channel_1).to have_received(:emit)
      .with(name, data, socket_id: socket_id)
    expect(channel_2).to have_received(:emit)
      .with(name, data, socket_id: socket_id)
  end
end

describe PusherFake::Server::Application, ".channels, requesting all" do
  subject { described_class }

  let(:request)  { instance_double(Rack::Request, params: {}) }
  let(:channels) { { "channel-1" => double, "channel-2" => double } }

  before do
    allow(PusherFake::Channel).to receive(:channels).and_return(channels)
  end

  it "returns a hash of all the channels" do
    hash = subject.channels(request)

    expect(hash).to eq(channels: { "channel-1" => {}, "channel-2" => {} })
  end
end

describe PusherFake::Server::Application,
         ".channels, requesting channels with a filter" do
  subject { described_class }

  let(:params)   { { "filter_by_prefix" => "public-" } }
  let(:request)  { instance_double(Rack::Request, params: params) }
  let(:channels) { { "public-1" => double, "presence-1" => double } }

  before do
    allow(PusherFake::Channel).to receive(:channels).and_return(channels)
  end

  it "returns a hash of the channels matching the filter" do
    hash = subject.channels(request)

    expect(hash).to eq(channels: { "public-1" => {} })
  end
end

describe PusherFake::Server::Application,
         ".channels, requesting user count for channels with a filter" do
  subject { described_class }

  let(:request)  { instance_double(Rack::Request, params: params) }
  let(:channels) { { "public-1" => double, "presence-1" => channel } }

  let(:channel) do
    instance_double(PusherFake::Channel::Presence,
                    connections: [double, double])
  end

  let(:params) do
    { "filter_by_prefix" => "presence-", "info" => "user_count" }
  end

  before do
    allow(PusherFake::Channel).to receive(:channels).and_return(channels)
  end

  it "returns hash of channels matching the filter and includes user count" do
    hash = subject.channels(request)

    expect(hash).to eq(channels: { "presence-1" => { user_count: 2 } })
  end
end

describe PusherFake::Server::Application,
         ".channels, requesting all channels with no channels occupied" do
  subject { described_class }

  let(:request) { instance_double(Rack::Request, params: {}) }

  before do
    allow(PusherFake::Channel).to receive(:channels).and_return({})
  end

  it "returns a hash of no channels" do
    hash = subject.channels(request)

    expect(hash).to eq(channels: {})
  end
end

describe PusherFake::Server::Application,
         ".channels, requesting a user count on a non-presence channel" do
  subject { described_class }

  let(:params)  { { "filter_by_prefix" => "public-", "info" => "user_count" } }
  let(:request) { instance_double(Rack::Request, params: params) }

  it "raises an error" do
    expect do
      subject.channels(request)
    end.to raise_error(subject::CHANNEL_FILTER_ERROR)
  end
end

describe PusherFake::Server::Application, ".channel, for an occupied channel" do
  subject { described_class }

  let(:name)     { "public-1" }
  let(:request)  { instance_double(Rack::Request, params: {}) }
  let(:channels) { { name => channel } }

  let(:channel) do
    instance_double(PusherFake::Channel::Presence, connections: [double])
  end

  before do
    allow(PusherFake::Channel).to receive(:channels).and_return(channels)
  end

  it "returns a hash with the occupied status" do
    hash = subject.channel(name, request)

    expect(hash).to eq(occupied: true)
  end
end

describe PusherFake::Server::Application, ".channel, for unoccupied channel" do
  subject { described_class }

  let(:name)     { "public-1" }
  let(:request)  { instance_double(Rack::Request, params: {}) }
  let(:channels) { { name => channel } }

  let(:channel) do
    instance_double(PusherFake::Channel::Presence, connections: [])
  end

  before do
    allow(PusherFake::Channel).to receive(:channels).and_return(channels)
  end

  it "returns a hash with the occupied status" do
    hash = subject.channel(name, request)

    expect(hash).to eq(occupied: false)
  end
end

describe PusherFake::Server::Application, ".channel, for an unknown channel" do
  subject { described_class }

  let(:request)  { instance_double(Rack::Request, params: {}) }
  let(:channels) { {} }

  before do
    allow(PusherFake::Channel).to receive(:channels).and_return(channels)
  end

  it "returns a hash with the occupied status" do
    hash = subject.channel("fake", request)

    expect(hash).to eq(occupied: false)
  end
end

describe PusherFake::Server::Application,
         ".channel, request user count for a presence channel" do
  subject { described_class }

  let(:name)     { "presence-1" }
  let(:params)   { { "info" => "user_count" } }
  let(:request)  { instance_double(Rack::Request, params: params) }
  let(:channels) { { name => channel } }

  let(:channel) do
    instance_double(PusherFake::Channel::Presence,
                    connections: [double, double])
  end

  before do
    allow(PusherFake::Channel).to receive(:channels).and_return(channels)
  end

  it "returns a hash with the occupied status" do
    hash = subject.channel(name, request)

    expect(hash).to eq(occupied: true, user_count: 2)
  end
end

describe PusherFake::Server::Application,
         ".channel, requesting a user count on a non-presence channel" do
  subject { described_class }

  let(:params)  { { "info" => "user_count" } }
  let(:request) { instance_double(Rack::Request, params: params) }

  it "raises an error" do
    expect do
      subject.channel("public-1", request)
    end.to raise_error(subject::CHANNEL_USER_COUNT_ERROR)
  end
end

describe PusherFake::Server::Application, ".users, for an occupied channel" do
  subject { described_class }

  let(:name)     { "public-1" }
  let(:user_1)   { instance_double(PusherFake::Connection, id: "1") }
  let(:user_2)   { instance_double(PusherFake::Connection, id: "2") }
  let(:channels) { { name => channel } }

  let(:channel) do
    instance_double(PusherFake::Channel::Public, connections: [user_1, user_2])
  end

  before do
    allow(PusherFake::Channel).to receive(:channels).and_return(channels)
  end

  it "returns a hash with the occupied status" do
    hash = subject.users(name)

    expect(hash).to eq(users: [{ id: user_1.id }, { id: user_2.id }])
  end
end

describe PusherFake::Server::Application, ".users, for an empty channel" do
  subject { described_class }

  let(:name)     { "public-1" }
  let(:channels) { { name => channel } }

  let(:channel) do
    instance_double(PusherFake::Channel::Public, connections: [])
  end

  before do
    allow(PusherFake::Channel).to receive(:channels).and_return(channels)
  end

  it "returns a hash with the occupied status" do
    hash = subject.users(name)

    expect(hash).to eq(users: [])
  end
end

describe PusherFake::Server::Application, ".users, for an unknown channel" do
  subject { described_class }

  let(:channels) { {} }

  before do
    allow(PusherFake::Channel).to receive(:channels).and_return(channels)
  end

  it "returns a hash with the occupied status" do
    hash = subject.users("fake")

    expect(hash).to eq(users: [])
  end
end
