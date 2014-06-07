When %{I request "$path"} do |path|
  wait do
    @response = Pusher.get(path)
  end
end

When %{I request "$path" with the following options:} do |path, table|
  wait do
    begin
      @response = Pusher.get(path, table.hashes.first)
    rescue => error
      @error = error
    end
  end
end

Then %{I should receive the following JSON:} do |string|
  expected = MultiJson.load(string)
  expected = expected.inject({}) do |result, (key, value)|
    result.merge(key.to_sym => value)
  end

  expect(@response).to eq(expected)
end

Then %{I should receive the following error:} do |string|
  expect(@error.message).to include(string.strip)
end

Then /^I should receive JSON for (\d+) users?$/ do |count|
  @response[:users].tap do |users|
    expect(users.length).to eq(count.to_i)

    users.map do |user|
      ObjectSpace._id2ref(user["id"].to_i)
    end.each do |object|
      expect(object).to be_a(EventMachine::WebSocket::Connection)
    end
  end
end
