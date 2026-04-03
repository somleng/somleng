class PhoneCallDecorator < SimpleDelegator
  NullCallDataRecord = Struct.new(:bill_sec, :start_time, :end_time)

  TWILIO_CALL_STATUS_MAPPINGS = {
    "queued" => "queued",
    "initiating" => "queued",
    "initiated" => "queued",
    "ringing" => "ringing",
    "answered" => "in-progress",
    "busy" => "busy",
    "failed" => "failed",
    "session_timeout" => "failed",
    "not_answered" => "no-answer",
    "completed" => "completed",
    "canceled" => "canceled"
  }.freeze

  TWILIO_CALL_DIRECTIONS = {
    "inbound" => "inbound",
    "outbound_api" => "outbound-api",
    "outbound_dial" => "outbound-dial"
  }.freeze

  class << self
    delegate :model_name, :human_attribute_name, to: :PhoneCall

    def statuses
      TWILIO_CALL_STATUS_MAPPINGS.values.uniq
    end

    def directions
      TWILIO_CALL_DIRECTIONS.values.uniq
    end

    def status_from(twilio_status)
      TWILIO_CALL_STATUS_MAPPINGS.select { |_k, v| v == twilio_status }.keys.uniq
    end

    def direction_from(twilio_status)
      TWILIO_CALL_DIRECTIONS.select { |_k, v| v == twilio_status }.keys.uniq
    end
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

  def carrier_sid
    carrier_id
  end

  def account_sid
    account_id
  end

  def phone_number_sid
    incoming_phone_number_id
  end

  def direction
    TWILIO_CALL_DIRECTIONS.fetch(super)
  end

  def duration
    call_data_record.bill_sec.to_s.presence
  end

  def status
    TWILIO_CALL_STATUS_MAPPINGS.fetch(super)
  end

  def to_formatted
    phone_number_formatter.format(object.to, format: :international)
  end

  def from_formatted
    phone_number_formatter.format(object.from, format: :international)
  end

  def price_formatted(**)
    price_formatter.format(object.price, **)
  end

  def call_data_record
    object.call_data_record || NullCallDataRecord.new
  end

  def incoming_phone_number
    object.incoming_phone_number&.decorated
  end

  def phone_call
    object
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
