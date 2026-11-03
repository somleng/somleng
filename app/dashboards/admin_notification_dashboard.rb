require "administrate/base_dashboard"

class AdminNotificationDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    user: Field::BelongsTo,
    topic: Field::String,
    email: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    user
    email
    topic
    created_at
  ].freeze
end
