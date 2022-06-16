require "administrate/base_dashboard"

class AccountDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    outbound_sip_trunk: Field::BelongsTo.with_options(
      transform_on_export: ->(field) { field.data&.id }
    ),
    phone_calls: Field::HasMany.with_options(sort_by: :sequence_number, direction: :desc),
    phone_numbers: Field::HasMany,
    id: Field::String,
    name: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime,
    status: Field::String,
    calls_per_second: Field::String,
    allowed_calling_codes: Field::String,
    metadata: Field::JSON.with_options(searchable: false)
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    carrier
    name
    status
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    carrier
    id
    name
    status
    calls_per_second
    outbound_sip_trunk
    created_at
    updated_at
    phone_calls
    phone_numbers
    allowed_calling_codes
    metadata
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(account)
    account.name
  end
end
