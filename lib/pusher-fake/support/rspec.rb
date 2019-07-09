# frozen_string_literal: true

require "pusher-fake/support/base"

# Reset channels between examples
RSpec.configure do |config|
  config.after(:each) do
    PusherFake::Channel.reset
  end
end
