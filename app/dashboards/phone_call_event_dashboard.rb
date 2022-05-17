require "administrate/base_dashboard"

class PhoneCallEventDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    phone_call: Field::BelongsTo,
    id: Field::String,
    params: Field::JSON.with_options(searchable: false),
    type: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    type
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    phone_call
    id
    type
    params
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
