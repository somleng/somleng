class SMSGatewayForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :sms_gateway, default: -> { SMSGateway.new }
  attribute :name

  validates :name, presence: true

  delegate :new_record?, :persisted?, :id, to: :sms_gateway

  def self.model_name
    ActiveModel::Name.new(self, nil, "SMSGateway")
  end

  def self.initialize_with(sms_gateway)
    new(
      sms_gateway:,
      name: sms_gateway.name
    )
  end

  def save
    return false if invalid?

    sms_gateway.attributes = {
      name:,
      carrier:
    }

    sms_gateway.save!
  end
end
