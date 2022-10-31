class SMSGateway < ApplicationRecord
  belongs_to :carrier
  has_many :channel_groups, class_name: "SMSGatewayChannelGroup", counter_cache: :channel_groups_count
  has_many :channels, class_name: "SMSGatewayChannel", counter_cache: :channels_count

  encrypts :device_token, deterministic: true, downcase: true

  before_create :create_device_token

  private

  def create_device_token
    self.device_token ||= SecureRandom.alphanumeric(24)
  end
end
