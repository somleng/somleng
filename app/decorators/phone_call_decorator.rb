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
    "outbound" => "outbound-api"
  }.freeze

  def self.model_name
    ActiveModel::Name.new(self, nil, "PhoneCall")
  end

  def self.human_attribute_name(*args)
    PhoneCall.human_attribute_name(*args)
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

  def price_formatted
    price_formatter.format(price, object.price_unit)
  end

  def call_data_record
    object.call_data_record || NullCallDataRecord.new
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
