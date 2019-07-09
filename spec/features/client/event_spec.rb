# frozen_string_literal: true

require "spec_helper"

feature "Client triggers a client event" do
  let(:event)           { "client-message" }
  let(:other_user)      { "Bob" }
  let(:public_channel)  { "chat" }
  let(:private_channel) { "private-chat" }

  before do
    connect
    connect_as(other_user)
  end

  scenario "on a subscribed private channel" do
    subscribe_to(private_channel)
    subscribe_to_as(private_channel, other_user)

    trigger(private_channel, event)

    expect(page).not_to have_event(event, on: private_channel)

    using_session(other_user) do
      expect(page).to have_event(event, on: private_channel)
    end
  end

  scenario "on a subscribed public channel" do
    subscribe_to(public_channel)
    subscribe_to_as(public_channel, other_user)

    trigger(public_channel, event)

    expect(page).not_to have_event(event, on: public_channel)

    using_session(other_user) do
      expect(page).not_to have_event(event, on: public_channel)
    end
  end

  protected

  def trigger(channel, event)
    page.execute_script(
      "Helpers.trigger(#{MultiJson.dump(channel)}, #{MultiJson.dump(event)})"
    )
  end
end
