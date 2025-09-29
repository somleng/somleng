class SMSGateway < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  has_many :messages
  has_many :channel_groups, class_name: "SMSGatewayChannelGroup"
  has_many :channels, class_name: "SMSGatewayChannel"
  has_many :app_devices, class_name: "ApplicationPushDevice", as: :owner, dependent: :destroy


  enumerize :device_type, in: %i[gateway app], default: :gateway,
    predicates: true, scope: :shallow

  encrypts :device_token, deterministic: true, downcase: true

  attribute :default_sender, PhoneNumberType.new

  before_create :create_device_token

  def connected?
    last_connected_at.present? && last_connected_at >= 5.minutes.ago
  end

  def receive_ping
    touch(:last_connected_at)
  end

  def disconnect!
    update_columns(last_connected_at: nil)
  end

  def available_channel_slots
    (all_channel_slots - configured_channel_slots).sort
  end

  def configured_channel_slots
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
