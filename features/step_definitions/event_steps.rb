When %{a "$event" event is triggered on the "$channel" channel} do |event, channel|
  Pusher[channel].trigger(event, {})
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

Then /^I should receive a "([^"]+)" event on the "([^"]+)" channel$/ do |event, channel|
  wait do
    events = page.evaluate_script("Pusher.instance.events[#{[channel, event].join(":").to_json}]")
    events.length.should == 1
  end
end

Then /^I should not receive a "([^"]+)" event on the "([^"]+)" channel$/ do |event, channel|
  wait do
    events = page.evaluate_script("Pusher.instance.events[#{[channel, event].join(":").to_json}]")
    events.should be_nil
  end
end

Then /^([^I]+) should receive a "([^"]+)" event on the "([^"]+)" channel$/ do |name, event, channel|
  using_session(name) do
    step %{I should receive a "#{event}" event on the "#{channel}" channel}
  end
end

Then /^([^I]+) should not receive a "([^"]+)" event on the "([^"]+)" channel$/ do |name, event, channel|
  using_session(name) do
    step %{I should not receive a "#{event}" event on the "#{channel}" channel}
  end
end
