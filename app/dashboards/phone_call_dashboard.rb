require "administrate/base_dashboard"

class PhoneCallDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    account: Field::BelongsTo.with_options(
      transform_on_export: ->(field) { field.data.id }
    ),
    sip_trunk: Field::BelongsTo,
    call_data_record: Field::BelongsTo.with_options(
      transform_on_export: ->(field) { field.data&.id }
    ),
    phone_call_events: Field::HasMany,
    events: Field::HasMany,
    recordings: Field::HasMany,
    tts_events: Field::HasMany,
    id: Field::String,
    to: Field::String,
    from: Field::String,
    voice_url: Field::String,
    voice_method: Field::String,
    status: Field::String,
    price: Field::String,
    price_unit: Field::String,
    status_callback_url: Field::String,
    status_callback_method: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime,
    external_id: Field::String,
    variables: Field::JSON.with_options(searchable: false, export: false),
    direction: Field::String,
    twiml: Field::Text.with_options(export: false)
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
    price
    price_unit
    status_callback_url
    status_callback_method
    created_at
    updated_at
    sip_trunk
    call_data_record
    events
    phone_call_events
    recordings
    tts_events
  ].freeze

  filters = PhoneCall.aasm.states.map(&:name).index_with do |status|
    ->(resources) { resources.where(status:) }
  end

  filters[:inbound] = ->(resources) { resources.inbound }
  filters[:outbound] = ->(resources) { resources.outbound }

  filters[:last_month] = ->(resources) { resources.where(created_at: 1.month.ago.all_month) }
  filters[:last_week] = ->(resources) { resources.where(created_at: 1.week.ago.all_week) }
  filters[:yesterday] = ->(resources) { resources.where(created_at: Date.yesterday.all_day) }
  filters[:today] = ->(resources) { resources.where(created_at: Date.current.all_day) }
  filters[:this_month] = ->(resources) { resources.where(created_at: Time.current.all_month) }

  COLLECTION_FILTERS = filters.freeze
end
