require "spec_helper"

describe PusherFake::Server::Application, ".call" do
  let(:body)        { stub(read: json) }
  let(:data)        { mock }
  let(:json)        { mock }
  let(:name)        { "event-name" }
  let(:event)       { { "channels" => channels, "name" => name, "data" => data, "socket_id" => socket_id } }
  let(:request)     { stub(body: body) }
  let(:channels)    { ["channel-1", "channel-2"] }
  let(:response)    { mock }
  let(:channel_1)   { stub(emit: true) }
  let(:channel_2)   { stub(emit: true) }
  let(:socket_id)   { stub }
  let(:environment) { mock }

  subject { PusherFake::Server::Application }

  before do
    response.stubs(finish: response)

    MultiJson.stubs(load: event)
    Rack::Request.stubs(new: request)
    Rack::Response.stubs(new: response)
    PusherFake::Channel.stubs(:factory).with(channels[0]).returns(channel_1)
    PusherFake::Channel.stubs(:factory).with(channels[1]).returns(channel_2)
  end

  it "creates a request" do
    subject.call(environment)
    Rack::Request.should have_received(:new).with(environment)
  end

  it "parses the request body as JSON" do
    subject.call(environment)
    MultiJson.should have_received(:load).with(json)
  end

  it "creates channels by name" do
    subject.call(environment)

    channels.each do |channel|
      PusherFake::Channel.should have_received(:factory).with(channel)
    end
  end

  it "emits the event to the channels" do
    subject.call(environment)
    channel_1.should have_received(:emit).with(name, data, socket_id: socket_id)
    channel_2.should have_received(:emit).with(name, data, socket_id: socket_id)
  end

  it "creates a Rack response with an empty JSON object" do
    subject.call(environment)
    Rack::Response.should have_received(:new).with("{}")
  end

  it "finishes the response" do
    subject.call(environment)
    response.should have_received(:finish).with()
  end

  it "returns the response" do
    subject.call(environment).should == response
  end
end
