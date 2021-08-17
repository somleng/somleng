class CarrierAPIController < APIController
  self.responder = JSONAPIResponder

  before_action -> { doorkeeper_authorize!(:carrier_api) }
end
