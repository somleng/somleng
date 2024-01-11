class MessageDecorator < SimpleDelegator
  TWILIO_MESSAGE_DIRECTIONS = {
    "inbound" => "inbound",
    "outbound_api" => "outbound-api",
    "outbound_call" => "outbound-call",
    "outbound_reply" => "outbound-reply",
    "outbound" => "outbound"
  }.freeze

  TWILIO_MESSAGE_STATUS_MAPPINGS = {
    "accepted" => "accepted",
    "scheduled" => "scheduled",
    "queued" => "queued",
    "sending" => "sending",
    "sent" => "sent",
    "failed" => "failed",
    "received" => "received",
    "canceled" => "canceled",
    "delivered" => "delivered"
  }.freeze

  def self.model_name
    ActiveModel::Name.new(self, nil, "Message")
  end

  def self.human_attribute_name(*)
    Message.human_attribute_name(*)
  end

  def self.statuses
    TWILIO_MESSAGE_STATUS_MAPPINGS.values.uniq
  end

  def self.directions
    TWILIO_MESSAGE_DIRECTIONS.values.uniq
  end

  def self.status_from(twilio_status)
    TWILIO_MESSAGE_STATUS_MAPPINGS.select { |_k, v| v == twilio_status }.keys.uniq
  end

  def self.direction_from(twilio_status)
    TWILIO_MESSAGE_DIRECTIONS.select { |_k, v| v == twilio_status }.keys.uniq
  end

  def from
    phone_number_formatter.format(super, format: :e164)
  end

  def to
    phone_number_formatter.format(super, format: :e164)
  end

  def sid
    id
  end

  def account_sid
    account_id
  end

  def phone_number_sid
    phone_number_id
  end

  def direction
    TWILIO_MESSAGE_DIRECTIONS.fetch(super)
  end

  def status
    TWILIO_MESSAGE_STATUS_MAPPINGS.fetch(super)
  end

  def price_formatted
    price_formatter.format(price, object.price_unit)
  end

  private

  def phone_number_formatter
    @phone_number_formatter ||= PhoneNumberFormatter.new
  end

  def price_formatter
    @price_formatter ||= PriceFormatter.new
  end

  def object
    __getobj__
  end
end
