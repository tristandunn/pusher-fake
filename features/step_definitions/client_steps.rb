Given "I change my socket ID" do
  page.execute_script("Pusher.instance.connection.socket_id = -1;")
end

Then "I should be connected" do
  wait_until do
    state = page.evaluate_script("Pusher.instance.connection.state")
    state == "connected"
  end
end

Then "I should not be connected" do
  wait_until do
    state = page.evaluate_script("Pusher.instance.connection.state")
    state == "unavailable"
  end
end
