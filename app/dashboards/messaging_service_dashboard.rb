require "administrate/base_dashboard"

class MessagingServiceDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    carrier: Field::BelongsTo,
    account: Field::BelongsTo,
    incoming_phone_numbers: Field::HasMany,
    messages: Field::HasMany,
    name: Field::String,
    inbound_message_behavior: Field::String,
    inbound_request_url: Field::String,
    inbound_request_method: Field::String,
    status_callback_url: Field::String,
    smart_encoding: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    carrier
    account
    inbound_message_behavior
    inbound_request_url
    inbound_request_method
    status_callback_url
    smart_encoding
    created_at
    updated_at
    incoming_phone_numbers
    messages
  ].freeze

  def display_resource(messaging_service)
    messaging_service.name
  end
end
