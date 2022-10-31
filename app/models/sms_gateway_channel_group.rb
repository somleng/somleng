class SMSGatewayChannelGroup < ApplicationRecord
  belongs_to :sms_gateway
  has_many :channels, class_name: "SMSGatewayChannel"
end
