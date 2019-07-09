# frozen_string_literal: true

require "spec_helper"

feature "Requesting user API endpoint" do
  let(:users)        { Pusher.get("/channels/#{channel_name}/users")[:users] }
  let(:channel_name) { "public-1" }

  before do
    connect
    connect_as "Bob"
  end

  scenario "with no users subscribed" do
    expect(users).to be_empty
  end

  scenario "with a single user subscribed" do
    subscribe_to(channel_name)

    expect(users.size).to eq(1)
  end

  scenario "with a multiple users subscribed" do
    subscribe_to(channel_name)
    subscribe_to_as(channel_name, "Bob")

    ids = PusherFake::Channel.channels[channel_name].connections.map(&:id)

    expect(users.size).to eq(2)

    users.each do |user|
      expect(ids).to include(user["id"])
    end
  end
end
