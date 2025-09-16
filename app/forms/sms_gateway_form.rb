class SMSGatewayForm
  extend Enumerize

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :sms_gateway, default: -> { SMSGateway.new }
  attribute :max_channels
  attribute :name
  attribute :default_sender, PhoneNumberType.new
  enumerize :device_type, in: SMSGateway.device_type.values, default: :gateway

  validates :name, presence: true
  validates :max_channels,
            numericality: {
              only_integer: true,
              greater_than: 0,
              less_than_or_equal_to: 256,
              allow_blank: true
            }

  delegate :new_record?, :persisted?, :id, to: :sms_gateway

  def self.model_name
    ActiveModel::Name.new(self, nil, "SMSGateway")
  end

  def self.initialize_with(sms_gateway)
    new(
      sms_gateway:,
      carrier: sms_gateway.carrier,
      name: sms_gateway.name,
      max_channels: sms_gateway.max_channels,
      default_sender: sms_gateway.default_sender,
      device_type: sms_gateway.device_type
    )
  end

  def save
    return false if invalid?

    sms_gateway.attributes = {
      name:,
      max_channels:,
      carrier:,
      default_sender:,
      device_type:
    }

    sms_gateway.save!
  end
end
