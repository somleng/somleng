require "administrate/base_dashboard"

class CarrierDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    accounts: Field::HasMany,
    inbound_sip_trunks: Field::HasMany,
    outbound_sip_trunks: Field::HasMany,
    phone_numbers: Field::HasMany,
    phone_calls: Field::HasMany.with_options(sort_by: :sequence_number, direction: :desc),
    id: Field::String,
    name: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    country_code: Field::String
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    country_code
    accounts
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    country_code
    created_at
    updated_at
    accounts
    inbound_sip_trunks
    outbound_sip_trunks
    phone_numbers
    phone_calls
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(carrier)
    "Carrier: #{carrier.name}"
  end
end
