class CarrierAPIController < APIController
  self.responder = JSONAPIResponder

  before_action -> { doorkeeper_authorize!(:carrier_api) }
  before_action :authorize_request!

  private

  def authorize_request!
    return render_unauthorized unless APIAuthorizationRequest.new(request).jwt_token?
  end

  def current_carrier
    @current_carrier ||= doorkeeper_token.application.owner
  end

  def respond_with_resource(resource, options = {})
    respond_with(:carrier_api, :v1, resource, **options)
  end
end
