require "wisper/rspec/matchers"

RSpec.configure do |config|
  config.include(Wisper::RSpec::BroadcastMatcher, type: :model)
end
