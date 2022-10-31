class SMSGatewayChannelForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :sms_gateway_channel, default: -> { SMSGatewayChannel.new }
  attribute :sms_gateway_id
  attribute :channel_group_id
  attribute :phone_number_id
  attribute :name
  attribute :slot_index
  attribute :route_prefixes, RoutePrefixesType.new

  validates :name, presence: true
  validates :sms_gateway_id, presence: true, if: :new_record?
  validates :slot_index,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  validate :validate_slot_index

  delegate :new_record?, :persisted?, :id, to: :sms_gateway_channel
  delegate :sms_gateway, to: :sms_gateway_channel

  def self.model_name
    ActiveModel::Name.new(self, nil, "SMSGatewayChannel")
  end

  def self.initialize_with(sms_gateway_channel)
    new(
      carrier: sms_gateway_channel.sms_gateway.carrier,
      sms_gateway_channel:,
      slot_index: sms_gateway_channel.slot_index,
      name: sms_gateway_channel.name,
      sms_gateway_id: sms_gateway_channel.sms_gateway_id,
      channel_group_id: sms_gateway_channel.sms_gateway_channel_group_id,
      phone_number_id: sms_gateway_channel.phone_number_id,
      route_prefixes: sms_gateway_channel.route_prefixes
    )
  end

  def save
    return false if invalid?

    sms_gateway_channel.name = name
    sms_gateway_channel.slot_index = slot_index
    sms_gateway_channel.route_prefixes = RoutePrefixesType.new.deserialize(route_prefixes)
    sms_gateway_channel.sms_gateway = find_sms_gateway if sms_gateway_id.present?
    sms_gateway_channel.channel_group = channel_group_id.present? ? find_channel_group : nil
    sms_gateway_channel.phone_number = phone_number_id.present? ? find_phone_number : nil

    sms_gateway_channel.save!
  end

  private

  def find_sms_gateway
    carrier.sms_gateways.find(sms_gateway_id)
  end

  def find_channel_group
    sms_gateway.channel_groups.find(channel_group_id)
  end

  def find_phone_number
    carrier.phone_numbers.find(phone_number_id)
  end

  def validate_slot_index
    return if slot_index.blank?
    return if slot_index.to_i == sms_gateway_channel.slot_index
    return if sms_gateway_id.blank?
    return unless find_sms_gateway.channels.exists?(slot_index:)

    errors.add(:slot_index, :taken)
  end
end
