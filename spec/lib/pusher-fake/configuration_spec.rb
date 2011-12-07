require "spec_helper"

describe PusherFake::Configuration do
  it { should have_configuration_option(:host).with_default("127.0.0.1") }
  it { should have_configuration_option(:port).with_default(8080) }
end
