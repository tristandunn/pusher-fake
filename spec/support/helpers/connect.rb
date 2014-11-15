module ConnectHelpers
  def connect(options = {})
    visit "/"

    expect(page).to have_content("Client connected.")

    if options[:channel]
      subscribe_to(options[:channel])
    end
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
