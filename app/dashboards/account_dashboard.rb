require "administrate/base_dashboard"

class AccountDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    sip_trunk: Field::BelongsTo,
    id: Field::String,
    type: Field::String,
    name: Field::String,
    default_tts_voice: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime,
    status: Field::String,
    calls_per_second: Field::String,
    allowed_calling_codes: Field::String,
    metadata: Field::JSON.with_options(searchable: false)
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    carrier
    name
    type
    status
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    carrier
    id
    name
    type
    status
    calls_per_second
    default_tts_voice
    sip_trunk
    created_at
    updated_at
    allowed_calling_codes
    metadata
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(account)
    account.name
  end
end
