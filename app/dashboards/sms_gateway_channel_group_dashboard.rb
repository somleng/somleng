require "administrate/base_dashboard"

class SMSGatewayChannelGroupDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    sms_gateway: Field::BelongsTo,
    name: Field::String,
    route_prefixes: Field::String,
    used_channel_slots: Field::String,
    created_at: Field::LocalTime,
    updated_at: Field::LocalTime
  }.freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    sms_gateway
    name
    route_prefixes
    used_channel_slots
    created_at
    updated_at
  ].freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    created_at
  ].freeze

  def display_resource(channel_group)
    channel_group.name
  end
end
