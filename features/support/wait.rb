module Capybara
  module Wait
    def wait(seconds = 0.25, &block)
      sleep(seconds) && yield
    end
  end
end

World(Capybara::Wait)
