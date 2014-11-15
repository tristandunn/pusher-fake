module SubscriptionHelpers
  def subscribe_to(channel)
    page.execute_script("Helpers.subscribe(#{MultiJson.dump(channel)})")

    expect(page).to have_content("Subscribed to #{channel}.")
  end

  def subscribe_to_as(channel, name)
    using_session(name) do
      subscribe_to(channel)
    end
  end

  def unsubscribe_from(channel)
    page.execute_script("Helpers.unsubscribe(#{MultiJson.dump(channel)})")

    expect(page).to have_content("Unsubscribed from #{channel}.")
  end

  def unsubscribe_from_as(channel, name)
    using_session(name) do
      unsubscribe_from(channel)
    end
  end
end

RSpec.configure do |config|
  config.include(SubscriptionHelpers)
end
