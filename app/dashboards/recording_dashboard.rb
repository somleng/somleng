require "administrate/base_dashboard"

class RecordingDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    phone_call: Field::BelongsTo,
    id: Field::String,
    external_id: Field::String,
    status: Field::String,
    status_callback_url: Field::String,
    status_callback_method: Field::String,
    file: Field::ActiveStorage.with_options(export: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    status
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    phone_call
    id
    file
    status
    status_callback_url
    status_callback_method
    external_id
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
