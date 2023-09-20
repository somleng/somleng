require "administrate/base_dashboard"

class ImportDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    resource_type: Field::String,
    status: Field::String,
    error_message: Field::String,
    user: Field::BelongsTo,
    carrier: Field::BelongsTo,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    resource_type
    status
    error_message
    user
    carrier
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    resource_type
    status
    error_message
    user
    carrier
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
