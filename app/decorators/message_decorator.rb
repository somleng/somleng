class MessageDecorator < SimpleDelegator
  TWILIO_MESSAGE_DIRECTIONS = {
    "inbound" => "inbound",
    "outbound" => "outbound-api"
  }.freeze

  # accepted, scheduled, canceled, queued, sending, sent, failed, delivered, undelivered, receiving, received, or read (WhatsApp only).
  # For more information, See https://www.twilio.com/docs/sms/api/message-resource#message-status-values

  TWILIO_MESSAGE_STATUS_MAPPINGS = {
    "queued" => "queued",
    "initiated" => "sending",
    "sent" => "sent",
    "failed" => "failed"
  }.freeze

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
