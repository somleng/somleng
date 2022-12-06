class SMSGatewayChannel < ApplicationRecord
  belongs_to :sms_gateway

  belongs_to :channel_group,
             class_name: "SMSGatewayChannelGroup",
             optional: true
end
