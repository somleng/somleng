class SMSGatewayChannelGroup < ApplicationRecord
  belongs_to :sms_gateway
  has_many :channels, class_name: "SMSGatewayChannel", foreign_key: :channel_group_id

  def configured_channel_slots
    channels.pluck(:slot_index).sort
  end
end
