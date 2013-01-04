module Capybara
  module Timing
    def wait(seconds = 0.25, &block)
      sleep(seconds) && yield
    end

    def timeout_after(seconds, &block)
      Timeout::timeout(seconds) do
        sleep(0.05) until yield
      end
    end
  end
end

World(Capybara::Timing)
