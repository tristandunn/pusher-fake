require "spec_helper"

describe PusherFake::Configuration do
  it { should have_configuration_option(:app_id).with_default("PUSHER_APP_ID") }
  it { should have_configuration_option(:key).with_default("PUSHER_API_KEY") }
  it { should have_configuration_option(:secret).with_default("PUSHER_API_SECRET") }
  it { should have_configuration_option(:socket_host).with_default("127.0.0.1") }
  it { should have_configuration_option(:socket_port).with_default(8080) }
  it { should have_configuration_option(:web_host).with_default("127.0.0.1") }
  it { should have_configuration_option(:web_port).with_default(8081) }
  it { should have_configuration_option(:webhooks).with_default([]) }
end
