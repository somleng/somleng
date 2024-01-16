require "administrate/base_dashboard"

class VerificationDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    verification_service: Field::BelongsTo,
    carrier: Field::BelongsTo,
    account: Field::BelongsTo,
    to: Field::String,
    channel: Field::String,
    status: Field::String,
    locale: Field::String,
    country_code: Field::String,
    verification_attempts_count: Field::Number,
    delivery_attempts_count: Field::Number,
    approved_at: Field::LocalTime,
    canceled_at: Field::LocalTime,
    expired_at: Field::LocalTime,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    verification_service
    carrier
    account
    to
    status
    channel
    country_code
    created_at
    expired_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    verification_service
    carrier
    account
    to
    channel
    status
    locale
    country_code
    verification_attempts_count
    delivery_attempts_count
    approved_at
    canceled_at
    expired_at
    created_at
    updated_at
  ].freeze
end
