require "administrate/base_dashboard"

class PhoneNumberDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    active_plan: Field::HasOne,
    plans: Field::HasMany,
    phone_calls: Field::HasMany,
    messages: Field::HasMany,
    id: Field::String,
    number: Field::String,
    country: Field::String,
    type: Field::String,
    visibility: Field::String,
    price: Field::String,
    region_name: Field::String,
    locality: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    carrier
    number
    country
    region_name
    locality
    type
    visibility
    price
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    country
    region_name
    locality
    type
    price
    carrier
    number
    visibility
    created_at
    updated_at
    active_plan
    plans
    phone_calls
    messages
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(phone_number)
    phone_number.number
  end
end
