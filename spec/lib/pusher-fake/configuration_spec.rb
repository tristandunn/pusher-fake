require "spec_helper"

describe PusherFake::Configuration do
  it { should have_configuration_option(:key).with_default("PUSHER_API_KEY") }
  it { should have_configuration_option(:logger).with_default(STDOUT.to_io) }
  it { should have_configuration_option(:verbose).with_default(false) }
  it { should have_configuration_option(:webhooks).with_default([]) }

  it do
    should have_configuration_option(:app_id).with_default("PUSHER_APP_ID")
  end

  it do
    should have_configuration_option(:secret).with_default("PUSHER_API_SECRET")
  end

  it "has configuration option :socket_options" do
    expect(subject.socket_options).to be_a(Hash)
    expect(subject.socket_options[:host]).to eq("127.0.0.1")
    expect(subject.socket_options[:port]).to be_a(Integer)
  end

  it "has configuration option :web_options" do
    expect(subject.web_options).to be_a(Hash)
    expect(subject.web_options[:host]).to eq("127.0.0.1")
    expect(subject.web_options[:port]).to be_a(Integer)
  end

  it "defaults socket and web ports to different values" do
    expect(subject.socket_options[:port]).not_to eq(subject.web_options[:port])
  end
end

describe PusherFake::Configuration, "#to_options" do
  it "includes the socket host as wsHost" do
    options = subject.to_options

    expect(options).to include(wsHost: subject.socket_options[:host])
  end

  it "includes the socket port as wsPort" do
    options = subject.to_options

    expect(options).to include(wsPort: subject.socket_options[:port])
  end

  it "supports passing custom options" do
    options = subject.to_options(custom: "option")

    expect(options).to include(custom: "option")
  end
end
