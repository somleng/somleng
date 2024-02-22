require "administrate/base_dashboard"

class ErrorLogDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    account: Field::BelongsTo,
    notifications: Field::HasMany,
    id: Field::String,
    error_message: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    carrier
    account
    error_message
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    carrier
    account
    error_message
    notifications
    created_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
