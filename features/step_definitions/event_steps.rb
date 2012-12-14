When %{a "$event" event is triggered on the "$channel" channel} do |event, channel|
  Pusher.trigger(channel, event, {})
end

When %{a "$event" event is triggered on the "$channel" channel, ignoring $name} do |event, channel, name|
  name      = nil if name == "me"
  socket_id = nil

  using_session(name) do
    socket_id = page.evaluate_script("Pusher.instance.connection.socket_id")
  end

  Pusher.trigger(channel, event, {}, socket_id: socket_id)
end

When %{a "$event" event is triggered on the following channels:} do |event, table|
  channels = table.hashes.collect { |hash| hash["name"] }

  Pusher.trigger(channels, event, {})
end

When %{I trigger the "$event" event on the "$channel" channel} do |event, channel|
  page.execute_script(%{
    var
    channel = Pusher.instance.channel(#{MultiJson.dump(channel)});
    channel.trigger(#{MultiJson.dump(event)}, {});
  })
end

When %{I manually trigger the "$event" event on the "$channel" channel} do |event, channel|
  page.execute_script(%{Pusher.instance.send_event(#{MultiJson.dump(event)}, {}, #{MultiJson.dump(channel)})})
end

Then /^([^ ]+) should receive a "([^"]+)" event on the "([^"]+)" channel$/ do |name, event, channel|
  name = nil if name == "I"

  using_session(name) do
    wait do
      events = page.evaluate_script("Pusher.instance.events[#{MultiJson.dump([channel, event].join(":"))}]")
      events.length.should == 1
    end
  end
end

Then /^([^ ]+) should not receive a "([^"]+)" event on the "([^"]+)" channel$/ do |name, event, channel|
  name = nil if name == "I"

  using_session(name) do
    wait do
      events = page.evaluate_script("Pusher.instance.events[#{MultiJson.dump([channel, event].join(":"))}]")
      events.should be_nil
    end
  end
end
