Given %{I subscribe to the "$channel" channel} do |channel|
  page.execute_script("Pusher.instance.subscribe(#{channel.to_json})")
end

Then %{I should be subscribed to the "$channel" channel} do |channel|
  wait_until(2) do
    subscribed = page.evaluate_script("Pusher.instance.channel(#{channel.to_json}).subscribed")
    subscribed == true
  end
end
