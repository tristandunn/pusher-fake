if ENV["CI"]
  require "coveralls"

  Coveralls.wear_merged! do
    add_filter "features/"
    add_filter "spec/"
  end
end
