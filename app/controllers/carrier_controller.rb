class CarrierController < APIController
  before_action -> { doorkeeper_authorize!(:carrier_api) }

  private

  def respond_with_resource(resource, options = {})
    super(resource, api_namespace: :carrier, **options)
  end


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
    @current_card_issuer ||= Carrier.find(doorkeeper_token.application.owner_id)
  end
end
