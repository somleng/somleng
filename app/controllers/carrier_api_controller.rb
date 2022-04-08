class CarrierAPIController < APIController
  self.responder = JSONAPIResponder

  before_action -> { doorkeeper_authorize!(:carrier_api) }

  private

  def validate_request_schema(with:, **options, &block)
    schema_options = options.delete(:schema_options) || {}
    schema_options[:carrier] = current_carrier

    super(
      with: with,
      schema_options: schema_options,
      **options, &block
    )
  end

  def current_carrier
    @current_carrier ||= doorkeeper_token.application.owner
  end

  def respond_with_resource(resource, options = {})
    respond_with(:carrier_api, :v1, resource, **options)
  end
end
