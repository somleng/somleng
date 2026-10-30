class SMSGatewayForm < ApplicationForm
  SENDER_ID_BEHAVIOR_HINTS = {
    passthrough: "Uses the sender ID provided in the incoming request.",
    fallback: "Uses the SMS Gateway's caller ID if none is provided (e.g., calls originating from the Verify API).",
    override: "Always replaces the incoming sender ID with the SMS Gateway's sender ID, ignoring any provided value."
  }.freeze

  attribute :carrier
  attribute :sms_gateway, default: -> { SMSGateway.new }
  attribute :sender_id_behavior, default: :passthrough
  attribute :max_channels
  attribute :name
  attribute :sender_id

  enumerize :sender_id_behavior,
            in: SMSGateway.sender_id_behavior.values,
            default: :passthrough,
            predicates: { prefix: true }

  validates :name, presence: true
  validates :max_channels,
            numericality: {
              only_integer: true,
              greater_than: 0,
              less_than_or_equal_to: 256,
              allow_blank: true
            }

  validates :sender_id,
             alphanumeric_sender_id_format: {
              allow_numeric: true,
              allow_blank: true
            },
            originator_id_behavior: {
              passthrough?: ->(form) { form.sender_id_behavior_passthrough? }
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
      sender_id: sms_gateway.sender_id,
      sender_id_behavior: sms_gateway.sender_id_behavior
    )
  end

  def save
    return false if invalid?

    sms_gateway.attributes = {
      name:,
      max_channels:,
      carrier:,
      sender_id:,
      sender_id_behavior:
    }

    sms_gateway.save!
  end

  def sender_id_behavior_options_for_select
    self.class.sender_id_behavior.values.map do
      [
        "#{it.text} <div class='form-text'>#{SENDER_ID_BEHAVIOR_HINTS.fetch(it.value.to_sym)}</div>".html_safe,
        it.value
      ]
    end
  end
end
