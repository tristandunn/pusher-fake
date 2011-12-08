require "spec_helper"

describe PusherFake::Channel::Public do
  let(:name) { "channel" }

  subject { PusherFake::Channel::Public }

  it "assigns the provided name" do
    channel = subject.new(name)
    channel.name.should == name
  end
end

describe PusherFake::Channel, "#authorized?" do
  let(:connection)     { stub }
  let(:authentication) { "auth" }

  subject { PusherFake::Channel::Public.new("name") }

  it "returns true" do
    subject.should be_authorized(connection, authentication)
  end
end
