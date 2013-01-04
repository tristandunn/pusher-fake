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
  page.execute_script("Pusher.instance.subscribe(#{MultiJson.dump(channel)})")
end

When %{I subscribe to the "$channel" channel with presence events} do |channel|
  page.execute_script(%{
    var list      = list      || document.querySelector("section ul"),
        count     = count     || document.querySelector("section header h1 span"),
        addClient = addClient || function(client) {
          var
          element = list.appendChild(document.createElement("li"));
          element.setAttribute("id", "client-" + client.id);

          if (client.info) {
            element.innerHTML = client.info.name;
          }
        },
        changeCount = changeCount || function(delta) {
          count.innerHTML = parseInt(count.innerHTML, 10) + delta;
        };

    Pusher.instance.subscribe(#{MultiJson.dump(channel)})
      .bind("pusher:subscription_succeeded", function(clients) {
        clients.each(addClient);

        count.innerHTML = clients.count;
      })
      .bind("pusher:member_added", function(client) {
        addClient(client);
        changeCount(1);
      })
      .bind("pusher:member_removed", function(client) {
        var item = list.querySelector("li#client-" + client.id);

        list.removeChild(item);

        changeCount(-1);
      });
  })
end

When %{I unsubscribe from the "$channel" channel} do |channel|
  page.execute_script("Pusher.instance.unsubscribe(#{MultiJson.dump(channel)})")
end

When %{$name unsubscribes from the "$channel" channel} do |name, channel|
  using_session(name) do
    step %{I unsubscribe from the "#{channel}" channel}
  end
end

Then %{I should be subscribed to the "$channel" channel} do |channel|
  timeout_after(5) do
    subscribed = page.evaluate_script(%{
      var
      channel = Pusher.instance.channel(#{MultiJson.dump(channel)});
      channel && channel.subscribed;
    })
    subscribed == true
  end
end

Then %{I should not be subscribed to the "$channel" channel} do |channel|
  wait do
    subscribed = page.evaluate_script(%{
      var
      channel = Pusher.instance.channel(#{MultiJson.dump(channel)});
      channel && channel.subscribed;
    })
    subscribed.should be_false
  end
end
