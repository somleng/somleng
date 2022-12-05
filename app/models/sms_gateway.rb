class SMSGateway < ApplicationRecord
  include Redis::Objects

  belongs_to :carrier
  has_many :messages
  has_many :channel_groups, class_name: "SMSGatewayChannelGroup"
  has_many :channels, class_name: "SMSGatewayChannel"

  encrypts :device_token, deterministic: true, downcase: true

  before_create :create_device_token

  value :last_connected_at, expiration: 5.minutes

  def connected?
    last_connected_at.value.present?
  end

  def receive_ping
    self.last_connected_at = Time.current
  end

  def disconnect!
    last_connected_at.delete
  end

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
