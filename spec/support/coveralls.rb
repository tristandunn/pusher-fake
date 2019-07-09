# frozen_string_literal: true

if ENV["CI"]
  require "coveralls"

  Coveralls.wear_merged! do
    add_filter "spec/"
  end
end
