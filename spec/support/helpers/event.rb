# frozen_string_literal: true

module EventHelpers
  def have_event(event, options = {})
    have_css("li", text: "Channel #{options[:on]} received #{event} event.")
  end
end

RSpec.configure do |config|
  config.include(EventHelpers)
end
