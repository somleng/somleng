require "administrate/base_dashboard"

class SMSGatewayDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    carrier: Field::BelongsTo,
    default_sender: Field::BelongsTo,
    channel_groups: Field::HasMany,
    name: Field::String,
    max_channels: Field::String,
    last_connected: Field::LocalTime,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    carrier
    name
    max_channels
    last_connected
    default_sender
    created_at
    updated_at
    channel_groups
  ].freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    last_connected
    created_at
  ].freeze

  def display_resource(sms_gateway)
    sms_gateway.name
  end
end
