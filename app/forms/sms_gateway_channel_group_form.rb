class SMSGatewayChannelGroupForm
  class IntegerArrayType < ActiveRecord::Type::String
    def cast(value)
      Array(value).reject(&:blank?).map(&:to_i)
    end
  end

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :channel_group, default: -> { SMSGatewayChannelGroup.new }
  attribute :sms_gateway_id
  attribute :name
  attribute :route_prefixes, RoutePrefixesType.new, default: []
  attribute :channels, IntegerArrayType.new, default: []

  validates :name, presence: true
  validates :sms_gateway_id, presence: true, if: :new_record?
  validate :validate_channels

  delegate :new_record?, :persisted?, :id, to: :channel_group

  def self.model_name
    ActiveModel::Name.new(self, nil, "SMSGatewayChannelGroup")
  end

  def self.initialize_with(channel_group)
    new(
      carrier: channel_group.sms_gateway.carrier,
      channel_group:,
      name: channel_group.name,
      sms_gateway_id: channel_group.sms_gateway_id,
      route_prefixes: channel_group.route_prefixes,
      channels: channel_group.configured_channel_slots
    )
  end

  def save
    return false if invalid?

    channel_group.name = name
    channel_group.sms_gateway ||= find_sms_gateway
    channel_group.route_prefixes = route_prefixes

    SMSGatewayChannelGroup.transaction do
      channel_group.save!
      SMSGatewayChannel.where(channel_group_id: channel_group.id).delete_all
      SMSGatewayChannel.insert_all!(channel_records) if channel_records.any?
    end
  end

  def sms_gateways_options_for_select
    DecoratedCollection.new(sms_gateways).map { [ _1.name, _1.id ] }
  end

  def channels_options_for_select(sms_gateway = channel_group.sms_gateway)
    (sms_gateway.available_channel_slots + channel_group.configured_channel_slots).sort
  end

  def sms_gateway_available_channels
    sms_gateways.includes(:channels).each_with_object({}) do |sms_gateway, result|
      result[sms_gateway.id] = channels_options_for_select(sms_gateway)
    end
  end

  private

  def sms_gateways
    carrier.sms_gateways
  end

  def channel_records
    @channel_records ||= channels.map do |slot_index|
      {
        sms_gateway_id: channel_group.sms_gateway.id,
        channel_group_id: channel_group.id,
        slot_index:
      }
    end
  end

  def find_sms_gateway
    sms_gateways.find(sms_gateway_id)
  end

  def validate_channels
    return if errors.any?

    sms_gateway = channel_group.sms_gateway || find_sms_gateway
    return if (channels - channels_options_for_select(sms_gateway)).empty?

    errors.add(:channels, :invalid)
  end
end
