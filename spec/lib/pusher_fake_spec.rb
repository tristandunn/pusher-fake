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
  let(:configuration) { mock }

  subject { PusherFake }

  before do
    PusherFake::Configuration.stubs(new: configuration)
    PusherFake.instance_variable_set("@configuration", nil)
  end

  after do
    PusherFake.instance_variable_set("@configuration", nil)
  end

  it "initializes a configuration object" do
    subject.configuration
    PusherFake::Configuration.should have_received(:new)
  end

  it "memoizes the configuration" do
    subject.configuration
    subject.configuration
    PusherFake::Configuration.should have_received(:new).once
  end

  it "returns the configuration" do
    subject.configuration.should == configuration
  end
end

describe PusherFake, ".javascript" do
  let(:options)       { { custom: "option" } }
  let(:configuration) { subject.configuration }

  subject { PusherFake }

  it "returns JavaScript setting the host and port to the configured options" do
    arguments = [configuration.key, configuration.to_options].map(&:to_json).join(",")

    subject.javascript.should == "new Pusher(#{arguments})"
  end

  it "supports passing custom options" do
    arguments = [configuration.key, configuration.to_options(options)].map(&:to_json).join(",")

    subject.javascript(options).should == "new Pusher(#{arguments})"
  end
end

describe PusherFake, ".info" do
  let(:logger)        { stub(info: true) }
  let(:message)       { "Hello world." }
  let(:configuration) { subject.configuration }

  subject { PusherFake }

  before do
    configuration.logger = logger
  end

  it "forwards message to Logger#info when verbose" do
    configuration.verbose = true

    subject.info(message)

    logger.should have_received(:info).with(message).once
  end

  it "does not forward message when not verbose" do
    configuration.verbose = false

    subject.info(message)

    logger.should have_received(:info).never
  end
end
