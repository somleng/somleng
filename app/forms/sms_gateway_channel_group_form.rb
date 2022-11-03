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
  attribute :route_prefixes, RoutePrefixesType.new
  attribute :channels, IntegerArrayType.new, default: []

  validates :name, presence: true
  validates :sms_gateway_id, presence: true, if: :new_record?

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
      channels: channel_group.used_channel_slots
    )
  end

  def save
    return false if invalid?

    channel_group.name = name
    channel_group.sms_gateway ||= find_sms_gateway!
    channel_group.route_prefixes = RoutePrefixesType.new.deserialize(route_prefixes)

    SMSGatewayChannelGroup.transaction do
      channel_group.save!
      SMSGatewayChannel.where(channel_group_id: channel_group.id).delete_all
      SMSGatewayChannel.insert_all!(channel_records) if channel_records.any?
    end
  end

  def sms_gateways_choices
    sms_gateways.map do |sms_gateway|
      {
        value: sms_gateway.id,
        label: sms_gateway.name,
        selected: channel_group.sms_gateway_id == sms_gateway.id,
        customProperties: {
          maxChannels: sms_gateway.max_channels
        }
      }
    end
  end

  def sms_gateways_options_for_select
    sms_gateways.map do |sms_gateway|
      [sms_gateway.name, sms_gateway.id, { data: { max_channels: sms_gateway.max_channels } }]
    end
  end

  def sms_gateways
    carrier.sms_gateways
  end

  def available_sms_gateway_channel_slots
    sms_gateway = channel_group.sms_gateway || find_sms_gateway
    return [] if sms_gateway.blank?

    sms_gateway.available_channel_slots
  end

  def channels_options_for_select
    (available_sms_gateway_channel_slots + channels).sort
  end

  private

  def channel_records
    @channel_records ||= channels.map do |slot_index|
      {
        sms_gateway_id: channel_group.sms_gateway.id,
        channel_group_id: channel_group.id,
        slot_index:
      }
    end
  end

  def find_sms_gateway!
    sms_gateways.find(sms_gateway_id)
  end

  def find_sms_gateway
    find_sms_gateway! if sms_gateway_id.present?
  end
end
