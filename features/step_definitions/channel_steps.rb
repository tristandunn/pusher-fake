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

When %{I subscribe to the "$channel" channel with presence events} do |channel|
  page.execute_script(%{
    var list    = document.querySelector("#presence ul"),
        count   = document.querySelector("#presence header h1 span"),
        channel = Pusher.instance.subscribe(#{channel.to_json});

    channel.bind("pusher:subscription_succeeded", function(clients) {
      count.innerHTML = clients.count;

      clients.each(function(client) {
        var
        element = list.appendChild(document.createElement("li"));
        element.setAttribute("id", "client-" + client.id);
        element.innerHTML = client.info && client.info.name
      });
    });
    channel.bind("pusher:member_added", function(client) {
      count.innerHTML = parseInt(count.innerHTML, 10) + 1;

      var
      element = list.appendChild(document.createElement("li"));
      element.setAttribute("id", "client-" + client.id);
      element.innerHTML = client.info && client.info.name
    });
    channel.bind("pusher:member_removed", function(client) {
      var item = list.querySelector("li#client-" + client.id);

      count.innerHTML = parseInt(count.innerHTML, 10) - 1;

      list.removeChild(item);
    });
  })
end

When %{I unsubscribe from the "$channel" channel} do |channel|
  page.execute_script("Pusher.instance.unsubscribe(#{channel.to_json})")
end

When %{$name unsubscribes from the "$channel" channel} do |name, channel|
  using_session(name) do
    step %{I unsubscribe from the "#{channel}" channel}
  end
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
