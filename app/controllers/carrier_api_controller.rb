class CarrierAPIController < APIController
  self.responder = JSONAPIResponder

  before_action -> { doorkeeper_authorize!(:carrier_api) }

  def current_carrier
    @current_carrier ||= doorkeeper_token.application.owner
  end

  def respond_with_resource(resource, options = {})
    respond_with(:carrier_api, :v1, resource, **options)
  end
end
