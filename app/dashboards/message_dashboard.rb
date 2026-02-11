require "administrate/base_dashboard"

class MessageDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    carrier: Field::BelongsTo,
    account: Field::BelongsTo,
    phone_number: Field::BelongsTo,
    incoming_phone_number: Field::BelongsTo,
    sms_gateway: Field::BelongsTo,
    messaging_service: Field::BelongsTo,
    balance_transaction: Field::HasOne,
    channel: Field::String,
    body: Field::String,
    segments: Field::String,
    encoding: Field::String,
    smart_encoded: Field::String,
    to: Field::String,
    from: Field::String,
    direction: Field::String,
    sms_url: Field::String,
    sms_method: Field::String,
    status: Field::String,
    status_callback_url: Field::String,
    beneficiary_country_code: Field::String,
    price: Field::String,
    price_unit: Field::String,
    validity_period: Field::String,
    error_code: Field::String,
    error_message: Field::String,
    accepted_at: Field::LocalTime,
    queued_at: Field::LocalTime,
    sending_at: Field::LocalTime,
    sent_at: Field::LocalTime,
    failed_at: Field::LocalTime,
    received_at: Field::LocalTime,
    canceled_at: Field::LocalTime,
    scheduled_at: Field::LocalTime,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime,
    events: Field::HasMany
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    carrier
    account
    from
    to
    direction
    status
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    carrier
    account
    phone_number
    incoming_phone_number
    sms_gateway
    messaging_service
    balance_transaction
    channel
    body
    segments
    encoding
    smart_encoded
    to
    from
    direction
    sms_url
    sms_method
    status
    status_callback_url
    beneficiary_country_code
    price
    price_unit
    validity_period
    error_code
    error_message
    accepted_at
    queued_at
    sending_at
    sent_at
    failed_at
    received_at
    canceled_at
    scheduled_at
    created_at
    updated_at
    events
  ].freeze

  filters = Message.aasm.states.map(&:name).index_with do |status|
    ->(resources) { resources.where(status:) }
  end

  filters[:inbound] = ->(resources) { resources.where(direction: [:inbound]) }
  filters[:outbound] = lambda { |resources|
    resources.where(direction: %i[outbound_api outbound_call outbound_reply])
  }
end
