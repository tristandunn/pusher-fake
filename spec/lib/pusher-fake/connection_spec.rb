require "spec_helper"

describe PusherFake::Connection do
  let(:socket) { stub }

  subject { PusherFake::Connection }

  it "assigns the provided socket" do
    connection = subject.new(socket)
    connection.socket.should == socket
  end
end

describe PusherFake::Connection, "#emit" do
  let(:data)    { { some: "data", good: true } }
  let(:json)    { Yajl::Encoder.encode(message) }
  let(:event)   { "name" }
  let(:socket)  { stub(:send) }
  let(:message) { { event: event, data: data } }

  subject { PusherFake::Connection.new(socket) }

  it "sends the event to the socket as JSON" do
    subject.emit(event, data)
    socket.should have_received(:send).with(json)
  end
end

describe PusherFake::Connection, "#establish" do
  let(:socket)  { stub }

  subject { PusherFake::Connection.new(socket) }

  before do
    subject.stubs(:emit)
  end

  it "emits the connection established event with the socket ID" do
    subject.establish
    subject.should have_received(:emit).with("pusher:connection_established", socket_id: socket.object_id)
  end
end
