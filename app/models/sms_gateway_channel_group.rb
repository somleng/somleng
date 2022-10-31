class SMSGatewayChannelGroup < ApplicationRecord
  belongs_to :sms_gateway, counter_cache: :channel_groups_count
  has_many :channels, class_name: "SMSGatewayChannel", counter_cache: :channels_count
end
