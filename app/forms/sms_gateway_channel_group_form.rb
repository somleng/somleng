class SMSGatewayChannelGroupForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :sms_gateway_channel_group, default: -> { SMSGatewayChannelGroup.new }
  attribute :sms_gateway_id
  attribute :name
  attribute :route_prefixes, RoutePrefixesType.new

  validates :name, presence: true
  validates :sms_gateway_id, presence: true, if: :new_record?

  delegate :new_record?, :persisted?, :id, to: :sms_gateway_channel_group

  def self.model_name
    ActiveModel::Name.new(self, nil, "SMSGatewayChannelGroup")
  end

  def self.initialize_with(sms_gateway_channel_group)
    new(
      carrier: sms_gateway_channel_group.sms_gateway.carrier,
      sms_gateway_channel_group:,
      name: sms_gateway_channel_group.name,
      sms_gateway_id: sms_gateway_channel_group.sms_gateway_id,
      route_prefixes: sms_gateway_channel_group.route_prefixes
    )
  end

  def save
    return false if invalid?

    sms_gateway_channel_group.name = name
    sms_gateway_channel_group.sms_gateway = find_sms_gateway if sms_gateway_id.present?
    sms_gateway_channel_group.route_prefixes = RoutePrefixesType.new.deserialize(route_prefixes)

    sms_gateway_channel_group.save!
  end

  private

  def find_sms_gateway
    carrier.sms_gateways.find(sms_gateway_id)
  end
end
