require "administrate/base_dashboard"

class IncomingPhoneNumberDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    carrier: Field::BelongsTo,
    phone_number_plan: Field::BelongsTo,
    account: Field::BelongsTo,
    phone_number: Field::BelongsTo,
    messaging_service: Field::BelongsTo,
    phone_calls: Field::HasMany,
    messages: Field::HasMany,
    id: Field::String,
    number: Field::String,
    status: Field::String,
    voice_url: Field::String,
    voice_method: Field::String,
    sms_url: Field::String,
    sms_method: Field::String,
    status_callback_url: Field::String,
    status_callback_method: Field::String,
    sip_domain: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    carrier
    account
    number
    status
    phone_number_plan
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    number
    status
    voice_url
    voice_method
    sms_url
    sms_method
    status_callback_url
    status_callback_method
    sip_domain
    carrier
    phone_number_plan
    phone_number
    messaging_service
    phone_calls
    messages
    number
    enabled
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(incoming_phone_number)
    incoming_phone_number.number
  end
end
