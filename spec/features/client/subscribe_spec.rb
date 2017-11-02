require "spec_helper"

feature "Client subscribing to a channel" do
  before do
    visit "/"

    # rubocop:disable RSpec/ExpectInHook
    expect(page).to have_content("Client connected.")
    # rubocop:enable RSpec/ExpectInHook
  end

  scenario "successfully subscribes to a channel" do
    subscribe_to("chat-message")

    expect(page).to have_content("Subscribed to chat-message.")
  end

  scenario "successfully subscribes to multiple channel" do
    subscribe_to("chat-enter")
    subscribe_to("chat-exit")

    expect(page).to have_content("Subscribed to chat-enter.")
    expect(page).to have_content("Subscribed to chat-exit.")
  end

  scenario "successfully subscribes to a private channel" do
    subscribe_to("private-message-bob")

    expect(page).to have_content("Subscribed to private-message-bob.")
  end

  scenario "successfully subscribes to a presence channel" do
    subscribe_to("presence-game-1")

    expect(page).to have_content("Subscribed to presence-game-1.")
  end

  scenario "unsuccessfully subscribes to a private channel" do
    override_socket_id("13.37")

    attempt_to_subscribe_to("private-message-bob")

    expect(page).not_to have_content("Subscribed to private-message-bob.")
  end

  scenario "unsuccessfully subscribes to a presence channel" do
    override_socket_id("13.37")

    attempt_to_subscribe_to("presence-game-1")

    expect(page).not_to have_content("Subscribed to presence-game-1.")
  end

  protected

  def attempt_to_subscribe_to(channel)
    page.execute_script("Helpers.subscribe(#{MultiJson.dump(channel)})")
  end

  def override_socket_id(value)
    page.execute_script(
      "Pusher.instance.connection.socket_id = #{MultiJson.dump(value)};"
    )
  end
end
