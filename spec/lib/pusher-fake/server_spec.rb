require "spec_helper"

describe PusherFake::Server, ".start" do
  subject { PusherFake::Server }

  before do
    subject.stubs(start_web_server: nil, start_socket_server: nil)
    EventMachine.stubs(run: nil)
  end

  it "runs the event loop" do
    subject.start

    expect(EventMachine).to have_received(:run).with()
  end

  it "starts the socket web server when run yields" do
    subject.start

    expect(subject).to have_received(:start_web_server).never

    EventMachine.stubs(:run).yields

    subject.start

    expect(subject).to have_received(:start_web_server).with()
  end

  it "starts the socket server when run yields" do
    subject.start

    expect(subject).to have_received(:start_socket_server).never

    EventMachine.stubs(:run).yields

    subject.start

    expect(subject).to have_received(:start_socket_server).with()
  end
end

describe PusherFake::Server, ".start_socket_server" do
  let(:data)          { stub }
  let(:socket)        { stub(onopen: nil, onmessage: nil, onclose: nil) }
  let(:options)       { configuration.socket_options }
  let(:connection)    { stub(establish: nil, process: nil) }
  let(:configuration) { stub(socket_options: { host: "192.168.0.1", port: 8080 }) }

  subject { PusherFake::Server }

  before do
    PusherFake.stubs(configuration: configuration)
    PusherFake::Channel.stubs(:remove)
    PusherFake::Connection.stubs(new: connection)
    EventMachine::WebSocket.stubs(:start).yields(socket)
  end

  it "creates a WebSocket server" do
    subject.start_socket_server

    expect(EventMachine::WebSocket).to have_received(:start).with(options)
  end

  it "defines an open callback on the socket" do
    subject.start_socket_server

    expect(socket).to have_received(:onopen).with()
  end

  it "creates a connection with the provided socket when onopen yields" do
    subject.start_socket_server

    expect(PusherFake::Connection).to have_received(:new).never

    socket.stubs(:onopen).yields

    subject.start_socket_server

    expect(PusherFake::Connection).to have_received(:new).with(socket)
  end

  it "establishes the connection when onopen yields" do
    subject.start_socket_server

    expect(connection).to have_received(:establish).never

    socket.stubs(:onopen).yields

    subject.start_socket_server

    expect(connection).to have_received(:establish).with()
  end

  it "defines a message callback on the socket when onopen yields" do
    subject.start_socket_server

    expect(socket).to have_received(:onmessage).never

    socket.stubs(:onopen).yields

    subject.start_socket_server

    expect(socket).to have_received(:onmessage).with()
  end

  it "triggers process on the connection when onmessage yields" do
    socket.stubs(:onopen).yields

    subject.start_socket_server

    expect(connection).to have_received(:process).never

    socket.stubs(:onmessage).yields(data)

    subject.start_socket_server

    expect(connection).to have_received(:process).with(data)
  end

  it "defines a close callback on the socket when onopen yields" do
    subject.start_socket_server

    expect(socket).to have_received(:onclose).never

    socket.stubs(:onopen).yields

    subject.start_socket_server

    expect(socket).to have_received(:onclose).with()
  end

  it "removes the connection from all channels when onclose yields" do
    socket.stubs(:onopen).yields

    subject.start_socket_server

    expect(PusherFake::Channel).to have_received(:remove).never

    socket.stubs(:onclose).yields

    subject.start_socket_server

    expect(PusherFake::Channel).to have_received(:remove).with(connection)
  end
end

describe PusherFake::Server, ".start_web_server" do
  let(:host)          { "192.168.0.1" }
  let(:port)          { 8081 }
  let(:server)        { stub(:start! => true, :ssl= => true) }
  let(:configuration) { stub(web_options: { host: host, port: port, ssl: true }) }

  subject { PusherFake::Server }

  before do
    Thin::Server.stubs(new: server)
    Thin::Logging.stubs(:silent=)
    PusherFake.stubs(configuration: configuration)
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

    expect(server).to have_received(:start!).with()
  end
end
