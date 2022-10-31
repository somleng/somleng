class SMSGatewayChannel < ApplicationRecord
  belongs_to :sms_gateway, counter_cache: :channels_count

  belongs_to :channel_group,
             class_name: "SMSGatewayChannelGroup",
             foreign_key: :sms_gateway_channel_group_id,
             counter_cache: :channels_count,
             optional: true

  belongs_to :phone_number, optional: true

  def all_route_prefixes
    return route_prefixes if route_prefixes.present?

    channel_group&.route_prefixes || []
  end
end
