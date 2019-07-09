# frozen_string_literal: true

module ConnectHelpers
  def connect(options = {})
    visit "/"

    expect(page).to have_content("Client connected.")

    subscribe_to(options[:channel]) if options[:channel]
  end

  def connect_as(name, options = {})
    using_session(name) do
      connect(options)
    end
  end
end

RSpec.configure do |config|
  config.include(ConnectHelpers)
end
