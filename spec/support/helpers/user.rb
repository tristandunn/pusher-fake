module UserHelpers
  def user_id(name = nil)
    using_session(name) do
      return page.evaluate_script("Pusher.instance.connection.socket_id")
    end
  end
end

RSpec.configure do |config|
  config.include(UserHelpers)
end
