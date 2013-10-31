require "spec_helper"

describe PusherFake::Configuration do
  it { should have_configuration_option(:app_id).with_default("PUSHER_APP_ID") }
  it { should have_configuration_option(:key).with_default("PUSHER_API_KEY") }
  it { should have_configuration_option(:secret).with_default("PUSHER_API_SECRET") }
  it { should have_configuration_option(:socket_options).with_default({ host: "127.0.0.1", port: 8080 }) }
  it { should have_configuration_option(:web_options).with_default({ host: "127.0.0.1", port: 8081 }) }
  it { should have_configuration_option(:webhooks).with_default([]) }
end

describe PusherFake::Configuration, "#socket_host=" do
  it "sets socket options host value" do
    silence_warnings do
      subject.socket_host = "192.168.0.1"
    end

    subject.socket_options[:host].should == "192.168.0.1"
  end
end

describe PusherFake::Configuration, "#socket_post=" do
  it "sets socket options host value" do
    silence_warnings do
      subject.socket_port = 443
    end

    subject.socket_options[:port].should == 443
  end
end

describe PusherFake::Configuration, "#web_host=" do
  it "sets web options host value" do
    silence_warnings do
      subject.web_host = "192.168.0.1"
    end

    subject.web_options[:host].should == "192.168.0.1"
  end
end

describe PusherFake::Configuration, "#web_post=" do
  it "sets web options host value" do
    silence_warnings do
      subject.web_port = 443
    end

    subject.web_options[:port].should == 443
  end
end

describe PusherFake::Configuration, "#to_options" do
  it "includes the socket host as wsHost" do
    subject.to_options.should include(wsHost: subject.socket_options[:host])
  end

  it "includes the socket port as wsPort" do
    subject.to_options.should include(wsPort: subject.socket_options[:port])
  end

  it "supports passing custom options" do
    subject.to_options(custom: "option").should include(custom: "option")
  end
end
