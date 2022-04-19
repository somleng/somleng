require "administrate/base_dashboard"

class PhoneNumberDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    account: Field::BelongsTo,
    phone_calls: Field::HasMany,
    id: Field::String,
    number: Field::String,
    enabled: Field::String,
    configuration: Field::HasOne,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    account
    number
    enabled
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    carrier
    account
    number
    enabled
    configuration
    created_at
    updated_at
    phone_calls
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
