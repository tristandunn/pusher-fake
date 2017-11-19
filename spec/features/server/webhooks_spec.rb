require "spec_helper"

feature "Receiving event webhooks" do
  let(:channel)          { "room-1" }
  let(:other_user)       { "Bob" }
  let(:presence_channel) { "presence-room-1" }

  before do
    events.clear

    PusherFake.configuration.webhooks = ["http://127.0.0.1:8082"]

    connect
    connect_as(other_user)
  end

  scenario "occupying a channel" do
    subscribe_to(channel)

    expect(events).to include_event("channel_occupied", "channel" => channel)

    subscribe_to_as(channel, other_user)

    expect(events.size).to eq(1)
  end

  scenario "vacating a channel" do
    subscribe_to(channel)
    subscribe_to_as(channel, other_user)

    unsubscribe_from(channel)

    expect(events.size).to eq(1)

    unsubscribe_from_as(channel, other_user)

    expect(events).to include_event("channel_vacated", "channel" => channel)
  end

  scenario "subscribing to a presence channel" do
    subscribe_to(presence_channel)

    expect(events).to include_event(
      "member_added",
      "channel" => presence_channel, "user_id" => user_id
    )

    subscribe_to_as(presence_channel, other_user)

    expect(events).to include_event(
      "member_added",
      "channel" => presence_channel, "user_id" => user_id(other_user)
    )
  end

  scenario "unsubscribing from a presence channel" do
    subscribe_to(presence_channel)
    subscribe_to_as(presence_channel, other_user)

    unsubscribe_from(presence_channel)

    expect(events).to include_event("member_added",
                                    "channel" => presence_channel,
                                    "user_id" => user_id)

    unsubscribe_from_as(presence_channel, other_user)

    expect(events).to include_event("member_added",
                                    "channel" => presence_channel,
                                    "user_id" => user_id(other_user))
  end

  protected

  def events
    sleep(1)

    WebhookHelper.mutex.synchronize do
      WebhookHelper.events
    end
  end

  def include_event(event, options = {})
    include(options.merge("name" => event))
  end
end
