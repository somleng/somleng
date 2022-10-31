class SMSGatewayChannel < ApplicationRecord
  belongs_to :sms_gateway

  belongs_to :channel_group,
             class_name: "SMSGatewayChannelGroup",
             foreign_key: :sms_gateway_channel_group_id,
             optional: true

  belongs_to :phone_number, optional: true

  def all_route_prefixes
    return route_prefixes if route_prefixes.present?

    channel_group&.route_prefixes || []
  end
end
