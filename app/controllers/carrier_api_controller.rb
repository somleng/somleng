class CarrierAPIController < APIController
  self.responder = JSONAPIResponder

  before_action -> { doorkeeper_authorize!(:carrier_api) }
  before_action :authorize_source_ip

  private

  def validate_request_schema(with:, **options, &block)
    schema_options = options.delete(:schema_options) || {}
    schema_options[:carrier] = current_carrier

    super(
      with:,
      schema_options:,
      **options,
      &block
    )
  end

  def authorize_source_ip
    return if current_carrier.api_allowed_ip_addresses.empty?
    return if current_carrier.api_allowed_ip_addresses.exists?(ip_address: request.remote_ip)

    head :unauthorized
  end

  def current_carrier
    @current_carrier ||= doorkeeper_token.application.owner
  end

  def respond_with_resource(resource, options = {})
    respond_with(:api, :carrier, :v1, resource, **options)
  end
end
