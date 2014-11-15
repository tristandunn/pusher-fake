require "spec_helper"

describe PusherFake, ".configure" do
  subject { PusherFake }

  it "yields the configuration" do
    expect { |block|
      subject.configure(&block)
    }.to yield_with_args(subject.configuration)
  end
end

describe PusherFake, ".configuration" do
  let(:configuration) { double }

  subject { PusherFake }

  before do
    PusherFake.instance_variable_set("@configuration", nil)

    allow(PusherFake::Configuration).to receive(:new).and_return(configuration)
  end

  after do
    PusherFake.instance_variable_set("@configuration", nil)
  end

  it "initializes a configuration object" do
    subject.configuration

    expect(PusherFake::Configuration).to have_received(:new)
  end

  it "memoizes the configuration" do
    2.times { subject.configuration }

    expect(PusherFake::Configuration).to have_received(:new).once
  end

  it "returns the configuration" do
    expect(subject.configuration).to eq(configuration)
  end
end

describe PusherFake, ".javascript" do
  let(:configuration) { subject.configuration }

  subject { PusherFake }

  it "returns JavaScript setting the host and port to the configured options" do
    arguments  = [configuration.key, configuration.to_options].map(&:to_json).join(",")
    javascript = subject.javascript

    expect(javascript).to eq("new Pusher(#{arguments})")
  end

  it "supports passing custom options" do
    options    = { custom: "option" }
    arguments  = [configuration.key, configuration.to_options(options)].map(&:to_json).join(",")
    javascript = subject.javascript(options)

    expect(javascript).to eq("new Pusher(#{arguments})")
  end
end

describe PusherFake, ".log" do
  let(:logger)        { double(:logger, :<< => "") }
  let(:message)       { "Hello world." }
  let(:configuration) { subject.configuration }

  subject { PusherFake }

  before do
    configuration.logger = logger
  end

  it "forwards message to logger when verbose" do
    configuration.verbose = true

    subject.log(message)

    expect(logger).to have_received(:<<).with("#{message}\n").once
  end

  it "does not forward message when not verbose" do
    configuration.verbose = false

    subject.log(message)

    expect(logger).to_not have_received(:<<)
  end
end
