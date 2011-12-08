require "spec_helper"

describe PusherFake::Server, ".start" do
  let(:data)          { stub }
  let(:socket)        { stub(onopen: nil, onmessage: nil) }
  let(:options)       { { host: configuration.host, port: configuration.port } }
  let(:connection)    { stub(process: nil) }
  let(:configuration) { stub(host: "192.168.0.1", port: 8181) }

  subject { PusherFake::Server }

  before do
    subject.stubs(:onopen)
    PusherFake.stubs(:configuration).returns(configuration)
    PusherFake::Connection.stubs(:new).returns(connection)
    EventMachine::WebSocket.stubs(:start).yields(socket)
  end

  it "creates a WebSocket server" do
    subject.start
    EventMachine::WebSocket.should have_received(:start).with(options)
  end

  it "creates a connection with the provided socket" do
    subject.start
    PusherFake::Connection.should have_received(:new).with(socket)
  end

  it "defines an open callback on the socket" do
    subject.start
    socket.should have_received(:onopen).with()
  end

  it "triggers onopen with the connection when the socket yields to onopen" do
    socket.stubs(:onopen).yields
    subject.start
    subject.should have_received(:onopen).with(connection)
  end

  it "defines a message callback on the socket" do
    subject.start
    socket.should have_received(:onmessage).with()
  end

  it "triggers process on the connection when the socket yields to onmessage" do
    socket.stubs(:onmessage).yields(data)
    subject.start
    connection.should have_received(:process).with(data)
  end
end

describe PusherFake::Server, ".onopen" do
  let(:connection) { stub(:establish) }

  subject { PusherFake::Server }

  before do
    EventMachine.stubs(:next_tick).yields
  end

  it "establishes the connection" do
    subject.onopen(connection)
    connection.should have_received(:establish).with()
  end
end
