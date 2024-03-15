require "administrate/base_dashboard"

class ErrorLogNotificationDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    error_log: Field::BelongsTo,
    user: Field::BelongsTo,
    email: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    error_log
    user
    email
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    error_log
    user
    email
    created_at
    updated_at
  ].freeze
end
