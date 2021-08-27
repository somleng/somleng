require "administrate/base_dashboard"

class PhoneCallDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    account: Field::BelongsTo,
    inbound_sip_trunk: Field::BelongsTo,
    call_data_record: Field::HasOne,
    phone_call_events: Field::HasMany,
    id: Field::String,
    to: Field::String,
    from: Field::String,
    voice_url: Field::String,
    voice_method: Field::String,
    status: Field::String,
    status_callback_url: Field::String,
    status_callback_method: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    external_id: Field::String,
    variables: Field::JSON.with_options(searchable: false),
    direction: Field::String,
    twiml: Field::Text
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    account
    from
    to
    direction
    status
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    account
    id
    from
    to
    direction
    status
    twiml
    external_id
    voice_url
    voice_method
    status_callback_url
    status_callback_method
    created_at
    updated_at
    inbound_sip_trunk
    call_data_record
    phone_call_events
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
