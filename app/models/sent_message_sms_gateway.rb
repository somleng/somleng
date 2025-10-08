class SentMessageSMSGateway < ApplicationRecord
  belongs_to :message
  belongs_to :sms_gateway
end
