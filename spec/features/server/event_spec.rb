require "spec_helper"

feature "Server triggers event" do
  let(:event)           { "message" }
  let(:other_user)      { "Bob" }
  let(:public_channel)  { "chat" }
  let(:private_channel) { "private-chat" }

  before do
    connect
    connect_as(other_user)
  end

  scenario "on a subscribed public channel" do
    subscribe_to(public_channel)
    subscribe_to_as(public_channel, other_user)

    trigger(public_channel, event)

    expect(page).to have_event(event, on: public_channel)

    using_session(other_user) do
      expect(page).to have_event(event, on: public_channel)
    end
  end

  scenario "on a previously subscribed public channel" do
    subscribe_to(public_channel)
    subscribe_to_as(public_channel, other_user)
    unsubscribe_from(public_channel)

    trigger(public_channel, event)

    expect(page).to_not have_event(event, on: public_channel)

    using_session(other_user) do
      expect(page).to have_event(event, on: public_channel)
    end
  end

  scenario "on an unsubscribed public channel" do
    trigger(public_channel, event)

    expect(page).to_not have_event(event, on: public_channel)

    using_session(other_user) do
      expect(page).to_not have_event(event, on: public_channel)
    end
  end

  scenario "on a subscribed private channel" do
    subscribe_to(private_channel)
    subscribe_to_as(private_channel, other_user)

    trigger(private_channel, event)

    expect(page).to have_event(event, on: private_channel)

    using_session(other_user) do
      expect(page).to have_event(event, on: private_channel)
    end
  end

  scenario "on a previously subscribed private channel" do
    subscribe_to(private_channel)
    subscribe_to_as(private_channel, other_user)
    unsubscribe_from(private_channel)

    trigger(private_channel, event)

    expect(page).to_not have_event(event, on: private_channel)

    using_session(other_user) do
      expect(page).to have_event(event, on: private_channel)
    end
  end

  scenario "on an unsubscribed private channel" do
    trigger(private_channel, event)

    expect(page).to_not have_event(event, on: private_channel)

    using_session(other_user) do
      expect(page).to_not have_event(event, on: private_channel)
    end
  end

  scenario "on multiple subscribed private channels" do
    subscribe_to("private-chat-1")
    subscribe_to_as("private-chat-2", other_user)

    trigger("private-chat-1", event)
    trigger("private-chat-2", event)

    expect(page).to have_event(event, on: "private-chat-1")

    using_session(other_user) do
      expect(page).to have_event(event, on: "private-chat-2")
    end
  end

  scenario "on a subscribed public channel, ignoring a user" do
    subscribe_to(public_channel)
    subscribe_to_as(public_channel, other_user)

    trigger(public_channel, event, socket_id: user_id(other_user))

    expect(page).to have_event(event, on: public_channel)

    using_session(other_user) do
      expect(page).to_not have_event(event, on: public_channel)
    end
  end

  protected

  def trigger(channel, event, options = {})
    Pusher.trigger(channel, event, {}, options)
  end
end
