# frozen_string_literal: true

require "spec_helper"

describe PusherFake::Configuration do
  it do
    expect(subject).to have_configuration_option(:disable_stats)
      .with_default(true)
  end

  it do
    expect(subject).to have_configuration_option(:key)
      .with_default("PUSHER_API_KEY")
  end

  it do
    expect(subject).to have_configuration_option(:logger)
      .with_default(STDOUT.to_io)
  end

  it do
    expect(subject).to have_configuration_option(:verbose)
      .with_default(false)
  end

  it do
    expect(subject).to have_configuration_option(:webhooks)
      .with_default([])
  end

  it do
    expect(subject).to have_configuration_option(:app_id)
      .with_default("PUSHER_APP_ID")
  end

  it do
    expect(subject).to have_configuration_option(:secret)
      .with_default("PUSHER_API_SECRET")
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

describe PusherFake::Configuration, "#app_id=" do
  subject { described_class.new }

  it "converts value to a string" do
    subject.app_id = 1_337

    expect(subject.app_id).to eq("1337")
  end
end

describe PusherFake::Configuration, "#to_options" do
  it "includes disable_stats as disableStats" do
    options = subject.to_options

    expect(options).to include(disableStats: subject.disable_stats)
  end

  it "includes the socket host as wsHost" do
    options = subject.to_options

    expect(options).to include(wsHost: subject.socket_options[:host])
  end

  it "includes the socket port as wsPort" do
    options = subject.to_options

    expect(options).to include(wsPort: subject.socket_options[:port])
  end

  it "includes the cluster by default" do
    options = subject.to_options

    expect(options).to include(cluster: "us-east-1")
  end

  it "supports passing custom options" do
    options = subject.to_options(custom: "option")

    expect(options).to include(custom: "option")
  end
end
