Then "I should be connected" do
  wait_until(2) do
    state = page.evaluate_script("Pusher.instance.connection.state")
    state == "connected"
  end
end

Then "I should not be connected" do
  wait_until(2) do
    state = page.evaluate_script("Pusher.instance.connection.state")
    state == "unavailable"
  end
end
