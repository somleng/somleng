class SMSGatewayDevice < ApplicationPushDevice
  belongs_to :sms_gateway, foreign_key: :owner_id
  has_many :message_send_requests, foreign_key: :device_id
end
