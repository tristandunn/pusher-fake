require "spec_helper"

describe PusherFake::Server, ".start" do
  let(:data)          { stub }
  let(:socket)        { stub(onopen: nil, onmessage: nil) }
  let(:options)       { { host: configuration.host, port: configuration.port } }
  let(:connection)    { stub(establish: nil, process: nil) }
  let(:configuration) { stub(host: "192.168.0.1", port: 8181) }

  subject { PusherFake::Server }

  before do
    PusherFake.stubs(:configuration).returns(configuration)
    PusherFake::Connection.stubs(:new).returns(connection)
    EventMachine::WebSocket.stubs(:start).yields(socket)
  end

  it "creates a WebSocket server" do
    subject.start
    EventMachine::WebSocket.should have_received(:start).with(options)
  end

  it "defines an open callback on the socket" do
    subject.start
    socket.should have_received(:onopen).with()
  end

  it "creates a connection with the provided socket when onopen yields" do
    subject.start
    PusherFake::Connection.should have_received(:new).never

    socket.stubs(:onopen).yields

    subject.start
    PusherFake::Connection.should have_received(:new).with(socket)
  end

  it "establishes the connection when onopen yields" do
    subject.start
    connection.should have_received(:establish).never

    socket.stubs(:onopen).yields

    subject.start
    connection.should have_received(:establish).with()
  end

  it "defines a message callback on the socket when onopen yields" do
    subject.start
    socket.should have_received(:onmessage).never

    socket.stubs(:onopen).yields

    subject.start
    socket.should have_received(:onmessage).with()
  end

  it "triggers process on the connection when onmessage yields" do
    socket.stubs(:onopen).yields

    subject.start
    connection.should have_received(:process).never

    socket.stubs(:onmessage).yields(data)

    subject.start
    connection.should have_received(:process).with(data)
  end
end
