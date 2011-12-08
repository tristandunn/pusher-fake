module Capybara
  module Wait
    def wait(seconds = Capybara.default_wait_time, &block)
      sleep(seconds) && yield
    end
  end
end

World(Capybara::Wait)
