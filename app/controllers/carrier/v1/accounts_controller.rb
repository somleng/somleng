class Carrier::V1::AccountsController < CarrierController
  def create
    validate_request_schema(
      with: Carrier::AccountRequestSchema,
      serializer_class: Carrier::AccountSerializer
    ) do |permitted_params|
      current_carrier.accounts.create!(permitted_params)
    end
  end
end
