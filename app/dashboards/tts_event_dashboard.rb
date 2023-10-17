require "administrate/base_dashboard"

class TTSEventDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    carrier: Field::BelongsTo,
    account: Field::BelongsTo,
    phone_call: Field::BelongsTo,
    provider: Field::String,
    num_chars: Field::Number,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    carrier
    account
    provider
    num_chars
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    carrier
    account
    phone_call
    provider
    num_chars
    created_at
    updated_at
  ].freeze
end
