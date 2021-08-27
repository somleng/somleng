require "administrate/base_dashboard"

class PhoneNumberDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    account: Field::BelongsTo,
    phone_calls: Field::HasMany,
    id: Field::String,
    number: Field::String,
    voice_url: Field::String,
    voice_method: Field::String,
    status_callback_url: Field::String,
    status_callback_method: Field::String,
    sip_domain: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    account
    number
    voice_url
    voice_method
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    carrier
    account
    id
    number
    voice_url
    voice_method
    status_callback_url
    status_callback_method
    sip_domain
    created_at
    updated_at
    phone_calls
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
