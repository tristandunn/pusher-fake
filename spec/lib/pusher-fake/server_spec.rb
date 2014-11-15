require "spec_helper"

describe PusherFake::Server, ".start" do
  subject { PusherFake::Server }

  before do
    allow(subject).to receive(:start_web_server).and_return(nil)
    allow(subject).to receive(:start_socket_server).and_return(nil)
    allow(EventMachine).to receive(:run).and_return(nil)
  end

  it "runs the event loop" do
    subject.start

    expect(EventMachine).to have_received(:run).with(no_args)
  end

  it "starts the socket web server when run yields" do
    subject.start

    expect(subject).to_not have_received(:start_web_server)

    allow(EventMachine).to receive(:run).and_yield

    subject.start

    expect(subject).to have_received(:start_web_server).with(no_args)
  end

  it "starts the socket server when run yields" do
    subject.start

    expect(subject).to_not have_received(:start_socket_server)

    allow(EventMachine).to receive(:run).and_yield

    subject.start

    expect(subject).to have_received(:start_socket_server).with(no_args)
  end
end

describe PusherFake::Server, ".start_socket_server" do
  let(:data)          { double }
  let(:socket)        { double(:socket, onopen: nil, onmessage: nil, onclose: nil) }
  let(:options)       { configuration.socket_options }
  let(:connection)    { double(:connection, establish: nil, process: nil) }
  let(:configuration) { double(:configuration, socket_options: { host: "192.168.0.1", port: 8080 }) }

  subject { PusherFake::Server }

  before do
    allow(PusherFake).to receive(:configuration).and_return(configuration)
    allow(PusherFake::Channel).to receive(:remove)
    allow(PusherFake::Connection).to receive(:new).and_return(connection)
    allow(EventMachine::WebSocket).to receive(:start).and_yield(socket)
  end

  it "creates a WebSocket server" do
    subject.start_socket_server

    expect(EventMachine::WebSocket).to have_received(:start).with(options)
  end

  it "defines an open callback on the socket" do
    subject.start_socket_server

    expect(socket).to have_received(:onopen).with(no_args)
  end

  it "creates a connection with the provided socket when onopen yields" do
    subject.start_socket_server

    expect(PusherFake::Connection).to_not have_received(:new)

    allow(socket).to receive(:onopen).and_yield

    subject.start_socket_server

    expect(PusherFake::Connection).to have_received(:new).with(socket)
  end

  it "establishes the connection when onopen yields" do
    subject.start_socket_server

    expect(connection).to_not have_received(:establish)

    allow(socket).to receive(:onopen).and_yield

    subject.start_socket_server

    expect(connection).to have_received(:establish).with(no_args)
  end

  it "defines a message callback on the socket when onopen yields" do
    subject.start_socket_server

    expect(socket).to_not have_received(:onmessage)

    allow(socket).to receive(:onopen).and_yield

    subject.start_socket_server

    expect(socket).to have_received(:onmessage).with(no_args)
  end

  it "triggers process on the connection when onmessage yields" do
    allow(socket).to receive(:onopen).and_yield

    subject.start_socket_server

    expect(connection).to_not have_received(:process)

    allow(socket).to receive(:onmessage).and_yield(data)

    subject.start_socket_server

    expect(connection).to have_received(:process).with(data)
  end

  it "defines a close callback on the socket when onopen yields" do
    subject.start_socket_server

    expect(socket).to_not have_received(:onclose)

    allow(socket).to receive(:onopen).and_yield

    subject.start_socket_server

    expect(socket).to have_received(:onclose).with(no_args)
  end

  it "removes the connection from all channels when onclose yields" do
    allow(socket).to receive(:onopen).and_yield

    subject.start_socket_server

    expect(PusherFake::Channel).to_not have_received(:remove)

    allow(socket).to receive(:onclose).and_yield

    subject.start_socket_server

    expect(PusherFake::Channel).to have_received(:remove).with(connection)
  end
end

describe PusherFake::Server, ".start_web_server" do
  let(:host)          { "192.168.0.1" }
  let(:port)          { 8081 }
  let(:server)        { double(:server, :start! => true, :ssl= => true) }
  let(:configuration) { double(:configuration, web_options: { host: host, port: port, ssl: true }) }

  subject { PusherFake::Server }

  before do
    allow(Thin::Server).to receive(:new).and_return(server)
    allow(Thin::Logging).to receive(:silent=)
    allow(PusherFake).to receive(:configuration).and_return(configuration)
  end

  it "silences the logging" do
    subject.start_web_server

    expect(Thin::Logging).to have_received(:silent=).with(true)
  end

  it "creates the web server" do
    subject.start_web_server

    expect(Thin::Server).to have_received(:new).with(host, port, PusherFake::Server::Application)
  end

  it "assigns custom options to the server" do
    subject.start_web_server

    expect(server).to have_received(:ssl=).with(true)
  end

  it "starts the web server" do
    subject.start_web_server

    expect(server).to have_received(:start!).with(no_args)
  end
end
