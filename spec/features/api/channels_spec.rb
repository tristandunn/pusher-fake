# frozen_string_literal: true

require "spec_helper"

feature "Requesting channel API endpoint" do
  let(:channel_name)  { "public-1" }
  let(:presence_name) { "presence-example" }

  before do
    connect
  end

  scenario "all channels, with none created" do
    expect(channels).to be_empty
  end

  scenario "all channels, with one created" do
    subscribe_to(channel_name)

    expect(channels).to have_key(channel_name)
  end

  scenario "all channels, with a filter" do
    subscribe_to("other")
    subscribe_to(channel_name)

    result = channels(filter_by_prefix: "pu")

    expect(result.size).to eq(1)
    expect(result).to have_key(channel_name)
  end

  scenario "all channels, with info attributes" do
    subscribe_to(presence_name)

    result = channels(filter_by_prefix: "presence-", info: "user_count")

    expect(result.size).to eq(1)
    expect(result).to have_key(presence_name)
    expect(result[presence_name]).to have_key("user_count")
    expect(result[presence_name]["user_count"]).to eq(1)
  end

  scenario "all channels, with invalid info attributes" do
    expect do
      channels(info: "user_count")
    end.to raise_error(/user_count may only be requested for presence channels/)
  end

  scenario "channel, with no occupants" do
    expect(channel[:occupied]).to eq(false)
  end

  scenario "channel, with an occupant" do
    subscribe_to(channel_name)

    expect(channel[:occupied]).to eq(true)
  end

  scenario "channel, with info attributes" do
    subscribe_to(presence_name)

    result = Pusher.get("/channels/#{presence_name}", info: "user_count")

    expect(result[:occupied]).to eq(true)
    expect(result[:user_count]).to eq(1)
  end

  scenario "channel, with invalid info attributes" do
    expect do
      channel(info: "user_count")
    end.to raise_error(
      /Cannot retrieve the user count unless the channel is a presence channel/
    )
  end

  protected

  def channel(options = {})
    Pusher.get("/channels/#{channel_name}", options)
  end

  def channels(options = {})
    Pusher.get("/channels", options)[:channels]
  end
end
