module MockHelpers
  require "drb"

  def stub_drb_object(params = {})
    drb_object = spy(DRb::DRbObject, params)
    allow(DRbObject).to receive(:new_with_uri).and_return(drb_object)
    drb_object
  end
end

RSpec.configure do |config|
  config.include(MockHelpers)
end
