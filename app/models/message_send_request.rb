class MessageSendRequest < ApplicationRecord
  belongs_to :message, optional: true
  belongs_to :device, class_name: "SMSGatewayDevice", optional: true
  belongs_to :sms_gateway
end
