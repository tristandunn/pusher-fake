# frozen_string_literal: true

require "spec_helper"

describe PusherFake::Server, ".start" do
  subject { described_class }

  before do
    allow(subject).to receive_messages(start_web_server: nil, start_socket_server: nil)
    allow(EventMachine).to receive(:run).and_return(nil)
  end

  it "prepends the chain trap handlers module to the WebSocket server" do
    allow(EventMachine::WebSocket.singleton_class).to receive(:prepend)

    subject.start

    expect(EventMachine::WebSocket.singleton_class).to have_received(:prepend)
      .with(PusherFake::Server::ChainTrapHandlers)
  end

  it "runs the event loop" do
    subject.start

    expect(EventMachine).to have_received(:run).with(no_args)
  end

  it "starts the socket web server when run yields" do
    subject.start

    expect(subject).not_to have_received(:start_web_server)

    allow(EventMachine).to receive(:run).and_yield

    subject.start

    expect(subject).to have_received(:start_web_server).with(no_args)
  end

  it "starts the socket server when run yields" do
    subject.start

    expect(subject).not_to have_received(:start_socket_server)

    allow(EventMachine).to receive(:run).and_yield

    subject.start

    expect(subject).to have_received(:start_socket_server).with(no_args)
  end
end

describe PusherFake::Server, ".start_socket_server" do
  subject { described_class }

  let(:data)    { double }
  let(:options) { configuration.socket_options }

  let(:configuration) do
    instance_double(PusherFake::Configuration,
                    socket_options: { host: "192.168.0.1", port: 8080 })
  end

  let(:connection) do
    instance_double(PusherFake::Connection, establish: nil, process: nil)
  end

  let(:socket) do
    instance_double(EventMachine::WebSocket::Connection,
                    onopen: nil, onmessage: nil, onclose: nil)
  end

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
    allow(socket).to receive(:onopen).and_yield

    subject.start_socket_server

    expect(PusherFake::Connection).to have_received(:new).with(socket)
  end

  it "establishes the connection when onopen yields" do
    allow(socket).to receive(:onopen).and_yield

    subject.start_socket_server

    expect(connection).to have_received(:establish).with(no_args)
  end

  it "defines a message callback on the socket when onopen yields" do
    allow(socket).to receive(:onopen).and_yield

    subject.start_socket_server

    expect(socket).to have_received(:onmessage).with(no_args)
  end

  it "triggers process on the connection when onmessage yields" do
    allow(socket).to receive(:onopen).and_yield
    allow(socket).to receive(:onmessage).and_yield(data)

    subject.start_socket_server

    expect(connection).to have_received(:process).with(data)
  end

  it "defines a close callback on the socket when onopen yields" do
    allow(socket).to receive(:onopen).and_yield

    subject.start_socket_server

    expect(socket).to have_received(:onclose).with(no_args)
  end

  it "removes the connection from all channels when onclose yields" do
    allow(socket).to receive(:onopen).and_yield
    allow(socket).to receive(:onclose).and_yield

    subject.start_socket_server

    expect(PusherFake::Channel).to have_received(:remove).with(connection)
  end
end

describe PusherFake::Server, ".start_web_server" do
  subject { described_class }

  let(:host)   { "192.168.0.1" }
  let(:port)   { 8081 }
  let(:server) { instance_double(Puma::Server, add_tcp_listener: nil, run: nil) }
  let(:thread) { instance_double(Thread) }

  let(:configuration) do
    instance_double(PusherFake::Configuration,
                    web_options: { host: host, port: port })
  end

  before do
    allow(Puma::Server).to receive(:new).and_return(server)
    allow(Thread).to receive(:new).and_return(thread)
    allow(PusherFake).to receive(:configuration).and_return(configuration)
  end

  it "creates the web server" do
    subject.start_web_server

    expect(Puma::Server).to have_received(:new)
      .with(PusherFake::Server::Application)
  end

  it "adds a TCP listener" do
    subject.start_web_server

    expect(server).to have_received(:add_tcp_listener).with(host, port)
  end

  it "starts the web server in a thread" do
    allow(Thread).to receive(:new).and_yield

    subject.start_web_server

    expect(server).to have_received(:run).with(no_args)
  end

  context "with SSL enabled" do
    let(:ssl_context)  { instance_double(Puma::MiniSSL::Context, :key= => nil, :cert= => nil) }
    let(:ssl_options)  { { private_key_file: "/path/to/key", cert_chain_file: "/path/to/cert" } }

    let(:configuration) do
      instance_double(PusherFake::Configuration,
                      web_options: { host: host, port: port, ssl: true, ssl_options: ssl_options })
    end

    before do
      allow(server).to receive(:add_ssl_listener)
      allow(Puma::MiniSSL::Context).to receive(:new).and_return(ssl_context)
    end

    it "adds an SSL listener" do
      subject.start_web_server

      expect(server).to have_received(:add_ssl_listener).with(host, port, ssl_context)
    end

    it "creates an SSL context with the key and cert" do
      subject.start_web_server

      expect(ssl_context).to have_received(:key=).with("/path/to/key")
      expect(ssl_context).to have_received(:cert=).with("/path/to/cert")
    end
  end
end
