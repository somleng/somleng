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

  def serializable_hash(*)
    super.merge(
      annotation: nil,
      answered_by: nil,
      caller_name: nil,
      direction: TWILIO_CALL_DIRECTIONS.fetch(object.direction),
      duration: call_data_record.bill_sec.to_s.presence,
      end_time: format_time(call_data_record.end_time),
      forwarded_from: nil,
      from: format_number(object.from, spaces: ""),
      from_formatted: format_number(object.from, format: :international),
      group_sid: nil,
      parent_call_sid: nil,
      phone_number_sid: object.incoming_phone_number_id,
      price: nil,
      price_unit: nil,
      start_time: format_time(call_data_record.start_time),
      status: TWILIO_CALL_STATUS_MAPPINGS.fetch(object.status),
      subresource_uris: {},
      to: format_number(object.to, spaces: ""),
      to_formatted: format_number(object.to, format: :international),
      uri: url_helpers.api_account_phone_call_url(object.account, object, format: :json)
    )
  end

  private

  def format_number(value, options = {})
    return value unless Phony.plausible?(value)

    Phony.format(value, options)
  end

  def call_data_record
    object.call_data_record || NullCallDataRecord.new
  end
end
