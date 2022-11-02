class SMSGateway < ApplicationRecord
  belongs_to :carrier
  has_many :channel_groups, class_name: "SMSGatewayChannelGroup"
  has_many :channels, class_name: "SMSGatewayChannel"

  encrypts :device_token, deterministic: true, downcase: true

  before_create :create_device_token

  def next_available_slot_index
    channels.size + 1
  end

  private

  def create_device_token
    self.device_token ||= SecureRandom.alphanumeric(24)
  end
end
