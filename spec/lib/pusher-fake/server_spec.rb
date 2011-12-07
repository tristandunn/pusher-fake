require "spec_helper"

describe PusherFake::Server, ".start" do
  let(:socket)        { stub }
  let(:options)       { { host: configuration.host, port: configuration.port } }
  let(:configuration) { stub(host: "192.168.0.1", port: 8181) }

  subject { PusherFake::Server }

  before do
    socket.stubs(:onopen)
    subject.stubs(:onopen)
    PusherFake.stubs(:configuration).returns(configuration)
    EventMachine::WebSocket.stubs(:start).yields(socket)
  end

  it "creates a WebSocket server" do
    subject.start
    EventMachine::WebSocket.should have_received(:start).with(options)
  end

  it "defines an open callback" do
    subject.start
    socket.should have_received(:onopen).with()
  end

  it "triggers onopen with the socket yields to onopen" do
    socket.stubs(:onopen).yields
    subject.start
    subject.should have_received(:onopen).with(socket)
  end
end

describe PusherFake::Server, ".onopen" do
  let(:socket)     { stub }
  let(:connection) { stub(:establish) }

  subject { PusherFake::Server }

  before do
    EventMachine.stubs(:next_tick).yields
    PusherFake::Connection.stubs(:new).returns(connection)
  end

  it "creates a connection with the provided socket" do
    subject.onopen(socket)
    PusherFake::Connection.should have_received(:new).with(socket)
  end

  it "establishes the connection" do
    subject.onopen(socket)
    connection.should have_received(:establish).with()
  end
end
