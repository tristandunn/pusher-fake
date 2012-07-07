require "spec_helper"

describe PusherFake::Server::Application, ".call" do
  let(:data)         { mock }
  let(:event)        { mock }
  let(:channel)      { stub(emit: nil) }
  let(:response)     { mock }
  let(:environment)  { mock }
  let(:channel_name) { mock }

  subject { PusherFake::Server::Application }

  before do
    subject.stubs(channel: channel_name, data: data, event: event)
    PusherFake::Channel.stubs(factory: channel)
    response.stubs(finish: response)
    Rack::Response.stubs(new: response)
  end

  it "assigns the environment" do
    subject.call(environment)
    subject.environment.should == environment
  end

  it "creates the channel by name" do
    subject.call(environment)
    PusherFake::Channel.should have_received(:factory).with(channel_name)
  end

  it "emits the event to the channel" do
    subject.call(environment)
    channel.should have_received(:emit).with(event, data)
  end

  it "creates a Rack response" do
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

describe PusherFake::Server::Application, ".channel" do
  let(:path)    { "/apps/PUSHER_APP_ID/channels/#{channel}/events" }
  let(:channel) { "channel-name" }

  subject { PusherFake::Server::Application }

  before do
    subject.stubs(path: path)
  end

  it "returns the channel name from the path" do
    subject.channel.should == channel
  end

  context "with a custom application ID" do
    let(:path)   { "/apps/#{app_id}/channels/#{channel}/events" }
    let(:app_id) { "test-id" }

    before do
      PusherFake.configuration.app_id = app_id
    end

    it "returns the channel name from the path" do
      subject.channel.should == channel
    end
  end
end

describe PusherFake::Server::Application, ".data" do
  let(:data)    { mock }
  let(:body)    { stub(read: json) }
  let(:json)    { mock }
  let(:request) { stub(body: body) }

  subject { PusherFake::Server::Application }

  before do
    subject.stubs(request: request)
    Yajl::Parser.stubs(parse: data)
  end

  it "parses the request body as JSON" do
    subject.data
    Yajl::Parser.should have_received(:parse).with(json)
  end

  it "returns the parsed JSON" do
    subject.data.should == data
  end
end

describe PusherFake::Server::Application, ".event" do
  let(:name)    { mock }
  let(:params)  { { "name" => name } }
  let(:request) { stub(params: params) }

  subject { PusherFake::Server::Application }

  before do
    subject.stubs(request: request)
  end

  it "creates a reqeust from the environment" do
    subject.event.should == name
  end
end

describe PusherFake::Server::Application, ".path" do
  let(:path)        { mock }
  let(:environment) { { "PATH_INFO" => path } }

  subject { PusherFake::Server::Application }

  before do
    subject.stubs(environment: environment)
  end

  it "returns the path for the environment" do
    subject.path.should == path
  end
end

describe PusherFake::Server::Application, ".request" do
  let(:environment) { mock }

  subject { PusherFake::Server::Application }

  before do
    Rack::Request.stubs(:new)
    subject.stubs(environment: environment)
  end

  it "creates a reqeust from the environment" do
    subject.request
    Rack::Request.should have_received(:new).with(environment)
  end
end
