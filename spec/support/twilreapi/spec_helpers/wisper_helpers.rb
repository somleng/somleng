module Twilreapi::SpecHelpers::WisperHelpers
  def assert_broadcasted!(broadcast_method, &block)
    expect { yield }.to broadcast(broadcast_method)
  end

  def assert_not_broadcasted!(broadcast_method, &block)
    expect { yield }.not_to broadcast(broadcast_method)
  end
end

RSpec.configure do |config|
  config.include(Twilreapi::SpecHelpers::WisperHelpers, :type => :model)
end
