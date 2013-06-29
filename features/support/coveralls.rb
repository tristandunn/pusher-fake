if ENV["CI"]
  require "coveralls"

  Coveralls.wear_merged!
end
