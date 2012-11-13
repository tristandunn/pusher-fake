When %{a "$event" event is triggered on the "$channel" channel} do |event, channel|
  Pusher.trigger([channel], event, {})
end

When %{I trigger the "$event" event on the "$channel" channel} do |event, channel|
  page.execute_script(%{
    var
    channel = Pusher.instance.channel(#{channel.to_json});
    channel.trigger(#{event.to_json}, {});
  })
end

When %{I manually trigger the "$event" event on the "$channel" channel} do |event, channel|
  page.execute_script(%{Pusher.instance.send_event(#{event.to_json}, {}, #{channel.to_json})})
end

Then /^([^ ]+) should receive a "([^"]+)" event on the "([^"]+)" channel$/ do |name, event, channel|
  name = nil if name == "I"

  using_session(name) do
    wait do
      events = page.evaluate_script("Pusher.instance.events[#{[channel, event].join(":").to_json}]")
      events.length.should == 1
    end
  end
end

Then /^([^ ]+) should not receive a "([^"]+)" event on the "([^"]+)" channel$/ do |name, event, channel|
  name = nil if name == "I"

  using_session(name) do
    wait do
      events = page.evaluate_script("Pusher.instance.events[#{[channel, event].join(":").to_json}]")
      events.should be_nil
    end
  end
end
