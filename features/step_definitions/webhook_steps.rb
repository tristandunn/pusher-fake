Then /^the server should have received the following (user )*event:$/ do |user_event, table|
  event = table.transpose.hashes.first

  using_session(event.delete("user")) do
    page.evaluate_script("Pusher.instance.connection.socket_id").tap do |socket_id|
      event.merge!("user_id" => socket_id.to_s)
    end
  end if user_event

  timeout_after(5) do
    $events.include?(event)
  end

  $events.replace([])
end

Then /^the server should have received no events$/ do
  wait do
    $events.should be_empty
  end
end
