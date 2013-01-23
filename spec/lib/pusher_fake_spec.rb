require "spec_helper"

describe PusherFake, ".configure" do
  let(:configuration) { mock }

  subject { PusherFake }

  before do
    subject.stubs(configuration: configuration)
  end

  it "yields the configuration" do
    expect { |block| subject.configure(&block) }.to yield_with_args(configuration)
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
