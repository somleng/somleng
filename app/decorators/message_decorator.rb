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

  class << self
    delegate :model_name, :human_attribute_name, to: :Message

    def statuses
      TWILIO_MESSAGE_STATUS_MAPPINGS.values.uniq
    end

    def directions
      TWILIO_MESSAGE_DIRECTIONS.values.uniq
    end

    def status_from(twilio_status)
      TWILIO_MESSAGE_STATUS_MAPPINGS.select { |_k, v| v == twilio_status }.keys.uniq
    end

    def direction_from(twilio_status)
      TWILIO_MESSAGE_DIRECTIONS.select { |_k, v| v == twilio_status }.keys.uniq
    end
  end

  def from
    phone_number_formatter.format(super, format: :e164)
  end

  def to
    phone_number_formatter.format(super, format: :e164)
  end

  def from_formatted
    phone_number_formatter.format(object.from, format: :international)
  end

  def to_formatted
    phone_number_formatter.format(object.to, format: :international)
  end

  def sid
    id
  end

  def account_sid
    account_id
  end

  def phone_number_sid
    incoming_phone_number_id
  end

  def direction
    TWILIO_MESSAGE_DIRECTIONS.fetch(super)
  end

  def status
    TWILIO_MESSAGE_STATUS_MAPPINGS.fetch(super)
  end

  def price_formatted(**)
    price_formatter.format(object.price, **)
  end

  def incoming_phone_number
    object.incoming_phone_number&.decorated
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
