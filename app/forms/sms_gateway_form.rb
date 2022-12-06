class SMSGatewayForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :sms_gateway, default: -> { SMSGateway.new }
  attribute :max_channels
  attribute :name

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
      name: sms_gateway.name,
      max_channels: sms_gateway.max_channels
    )
  end

  def save
    return false if invalid?

    sms_gateway.attributes = {
      name:,
      max_channels:,
      carrier:
    }

    sms_gateway.save!
  end
end
