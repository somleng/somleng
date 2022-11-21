class SMSGateway < ApplicationRecord
  belongs_to :carrier
  has_many :messages
  has_many :channel_groups, class_name: "SMSGatewayChannelGroup"
  has_many :channels, class_name: "SMSGatewayChannel"

  encrypts :device_token, deterministic: true, downcase: true

  before_create :create_device_token

  def available_channel_slots
    (all_channel_slots - used_channel_slots).sort
  end

  def used_channel_slots
    channels.pluck(:slot_index).sort
  end

  private

  def all_channel_slots
    return [] if max_channels.blank?

    (1..max_channels).to_a
  end

  def create_device_token
    self.device_token ||= SecureRandom.alphanumeric(24)
  end
end
