class PhoneCallDecorator < SimpleDelegator
  NullCallDataRecord = Struct.new(:bill_sec, :start_time, :end_time)

  TWILIO_CALL_STATUS_MAPPINGS = {
    "queued" => "queued",
    "initiated" => "queued",
    "ringing" => "ringing",
    "answered" => "in-progress",
    "busy" => "busy",
    "failed" => "failed",
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
    format_number(super, spaces: "")
  end

  def to
    format_number(super, spaces: "")
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
    format_number(__getobj__.to, format: :international)
  end

  def from_formatted
    format_number(__getobj__.from, format: :international)
  end

  def price_formatted
    return if price.blank?

    ActiveSupport::NumberHelper.number_to_currency(
      __getobj__.price,
      unit: Money::Currency.new(__getobj__.price_unit).symbol,
      precision: 6
    )
  end

  def call_data_record
    __getobj__.call_data_record || NullCallDataRecord.new
  end

  def format_number(value, options = {})
    return value unless Phony.plausible?(value)

    Phony.format(value, options)
  end
end
