require "spec_helper"

feature "Client on a presence channel" do
  let(:other_user) { "Bob" }

  before do
    connect
  end

  scenario "subscribing to a presence channel" do
    subscribe_to("presence-game-1")

    expect(page).to have_clients(1, in: "presence-game-1")
  end

  scenario "subscribing to a presence channel, with existing users" do
    connect_as(other_user, channel: "presence-game-1")

    subscribe_to("presence-game-1")

    expect(page).to have_clients(2, in: "presence-game-1", named: "Alan Turing")
  end

  scenario "member entering notification" do
    subscribe_to("presence-game-1")

    connect_as(other_user, channel: "presence-game-1")

    expect(page).to have_clients(2, in: "presence-game-1")
  end

  scenario "member leaving notification" do
    connect_as(other_user, channel: "presence-game-1")
    subscribe_to("presence-game-1")

    expect(page).to have_clients(2, in: "presence-game-1")

    unsubscribe_from_as("presence-game-1", other_user)

    expect(page).to have_clients(1, in: "presence-game-1")
  end

  scenario "other client connecting" do
    subscribe_to("presence-game-1")

    connect_as(other_user)

    expect(page).to have_clients(1, in: "presence-game-1")
  end

  protected

  def have_clients(count, options = {})
    have_css("li.channel-#{options[:in]}", count: count, text: options[:named])
  end
end
