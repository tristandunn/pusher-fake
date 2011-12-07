module PusherFake
  class Instance
    class << self
      attr_accessor :instance
    end

    def self.start
      self.instance ||= fork { PusherFake::Server.start }
    end

    def self.stop
      Process.kill("QUIT", self.instance) if self.instance
    end
  end
end

PusherFake::Instance.start

Before("@disable-server") do
  PusherFake::Instance.stop
end

After("@disable-server") do
  PusherFake::Instance.start
end

at_exit do
  PusherFake::Instance.stop
end
