require "administrate/base_dashboard"

class PhoneNumberDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    account: Field::BelongsTo,
    phone_calls: Field::HasMany,
    messages: Field::HasMany,
    id: Field::String,
    number: Field::String,
    country: Field::String,
    type: Field::String,
    enabled: Field::String,
    configuration: Field::HasOne,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    number
    country
    type
    account
    enabled
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    country
    type
    carrier
    account
    number
    enabled
    configuration
    created_at
    updated_at
    phone_calls
    messages
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(phone_number)
    phone_number.number
  end
end
