class PhoneCallSerializer < ResourceSerializer
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
  }

  NullCallDataRecord = Struct.new(:bill_sec, :start_time, :end_time)

  def attributes
    super.merge(
      annotation: nil,
      answered_by: nil,
      caller_name: nil,
      direction: nil,
      duration: nil,
      end_time: nil,
      forwarded_from: nil,
      from: nil,
      from_formatted: nil,
      group_sid: nil,
      parent_call_sid: nil,
      phone_number_sid: nil,
      price: nil,
      price_unit: nil,
      start_time: nil,
      status: nil,
      subresource_uris: nil,
      to: nil,
      to_formatted: nil,
      uri: nil
    )
  end

  def annotation; end

  def answered_by; end

  def caller_name; end

  def direction
    TWILIO_CALL_DIRECTIONS.fetch(super)
  end

  def duration
    call_data_record.bill_sec.to_s.presence
  end

  def end_time
    format_time(call_data_record.end_time)
  end

  def forwarded_from; end

  def from
    format_number(super, spaces: "")
  end

  def from_formatted
    format_number(__getobj__.from, format: :international)
  end

  def group_sid; end

  def parent_call_sid; end

  def phone_number_sid
    phone_number_id
  end

  def price; end

  def price_unit; end

  def start_time
    format_time(call_data_record.start_time)
  end

  def status
    TWILIO_CALL_STATUS_MAPPINGS.fetch(super)
  end

  def subresource_uris
    {}
  end

  def to
    format_number(super, spaces: "")
  end

  def to_formatted
    format_number(__getobj__.to, format: :international)
  end

  def uri
    url_helpers.account_phone_call_url(account, __getobj__, format: :json)
  end

  private

  def format_number(value, options = {})
    return value unless Phony.plausible?(value)

    Phony.format(value, options)
  end

  def call_data_record
    __getobj__.call_data_record || NullCallDataRecord.new
  end
end
