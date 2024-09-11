class SMSGatewayForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :sms_gateway, default: -> { SMSGateway.new }
  attribute :max_channels
  attribute :name
  attribute :default_sender_id

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
      default_sender_id: sms_gateway.default_sender_id
    )
  end

  def save
    return false if invalid?

    sms_gateway.attributes = {
      name:,
      max_channels:,
      carrier:,
      default_sender: default_sender_id.present? && default_sender_scope.find(default_sender_id)
    }

    sms_gateway.save!
  end

  def default_sender_options_for_select
    default_sender_scope.map do |phone_number|
      [ phone_number.decorated.number_formatted, phone_number.id ]
    end
  end

  private

  def default_sender_scope
    carrier.phone_numbers.available.where(type: :alphanumeric_sender_id)
  end
end
