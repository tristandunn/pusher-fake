Given %{I am subscribed to the "$channel" channel} do |channel|
  step %{I subscribe to the "#{channel}" channel}
  step %{I should be subscribed to the "#{channel}" channel}
end

Given %{$name is subscribed to the "$channel" channel} do |name, channel|
  using_session(name) do
    step %{I am subscribed to the "#{channel}" channel}
  end
end

When %{I subscribe to the "$channel" channel} do |channel|
  page.execute_script("Pusher.instance.subscribe(#{channel.to_json})")
end

When %{I unsubscribe from the "$channel" channel} do |channel|
  page.execute_script("Pusher.instance.unsubscribe(#{channel.to_json})")
end

Then %{I should be subscribed to the "$channel" channel} do |channel|
  wait_until do
    subscribed = page.evaluate_script(%{
      var
      channel = Pusher.instance.channel(#{channel.to_json});
      channel && channel.subscribed;
    })
    subscribed == true
  end
end

Then %{I should not be subscribed to the "$channel" channel} do |channel|
  wait do
    subscribed = page.evaluate_script(%{
      var
      channel = Pusher.instance.channel(#{channel.to_json});
      channel && channel.subscribed;
    })
    subscribed.should be_false
  end
end
