class ProcessCDR < ApplicationWorkflow
  attr_accessor  :raw_payload, :cdr

  def initialize(raw_payload)
    super()
    @raw_payload = raw_payload
    @cdr = decode_payload
  end

  def call
    call_data_record = create_call_data_record
    update_phone_call_status(call_data_record.phone_call)
    notify_status_callback_url(call_data_record.phone_call)
    create_event(call_data_record.phone_call)
  end

  private

  def create_call_data_record
    phone_call = find_phone_call

    CallDataRecord.create_or_find_by!(phone_call:) do |call_data_record|
      call_data_record.hangup_cause = cdr_variables.fetch("hangup_cause")
      call_data_record.direction = cdr_variables.fetch("direction")
      call_data_record.duration_sec = cdr_variables.fetch("duration")
      call_data_record.bill_sec = cdr_variables.fetch("billsec")
      call_data_record.start_time = parse_epoch(cdr_variables.fetch("start_epoch"))
      call_data_record.end_time = parse_epoch(cdr_variables.fetch("end_epoch"))
      call_data_record.answer_time = parse_epoch(cdr_variables.fetch("answer_epoch"))
      call_data_record.sip_term_status = cdr_variables["sip_term_status"]
      call_data_record.sip_invite_failure_status = cdr_variables["sip_invite_failure_status"]
      call_data_record.sip_invite_failure_phrase = URI.decode_www_form_component(
        cdr_variables.fetch("sip_invite_failure_phrase", "")
      ).presence
      call_data_record.file = {
        io: StringIO.new(cdr.to_json),
        filename: "#{cdr_variables.fetch('uuid')}.json",
        content_type: "application/json"
      }
    end
  end

  def update_phone_call_status(phone_call)
    UpdatePhoneCallStatus.call(
      phone_call,
      {
        event_type: :completed,
        answer_epoch: phone_call.call_data_record.answer_time.to_i,
        sip_term_status: phone_call.call_data_record.sip_term_status,
        sip_invite_failure_status: phone_call.call_data_record.sip_invite_failure_status
      }
    )
  end

  def notify_status_callback_url(phone_call)
    return if phone_call.status_callback_url.blank?

    ExecuteWorkflowJob.perform_later(
      TwilioAPI::NotifyWebhook.to_s,
      account: phone_call.account,
      url: phone_call.status_callback_url,
      http_method: phone_call.status_callback_method,
      params: TwilioAPI::Webhook::VoiceStatusCallbackSerializer.new(
        PhoneCallDecorator.new(phone_call)
      ).serializable_hash
    )
  end

  def create_event(phone_call)
    CreateEvent.call(eventable: phone_call, type: "phone_call.completed")
  end

  def parse_epoch(epoch)
    epoch = epoch.to_i
    Time.at(epoch) if epoch.positive?
  end

  def find_phone_call
    phone_call_id = cdr_variables["sip_rh_X-Somleng-CallSid"]
    phone_call_id ||= cdr_variables["sip_h_X-Somleng-CallSid"]

    return PhoneCall.find(phone_call_id) if phone_call_id.present?

    PhoneCall.find_by!(external_id: cdr_variables.fetch("uuid"))
  end

  def cdr_variables
    cdr.fetch("variables")
  end

  # https://github.com/signalwire/freeswitch/blob/6a13dee6f816c0b801676c084ab91942dd338cc5/src/mod/event_handlers/mod_json_cdr/mod_json_cdr.c#L316
  def decode_payload
    payload = ActiveSupport::Gzip.decompress(Base64.decode64(raw_payload))

    json_payload = JSON.parse(payload) rescue nil

    return json_payload if json_payload.present?

    payload = URI.decode_www_form(payload).to_h.fetch("cdr")
    payload = Base64.decode64(payload)
    payload = payload.gsub(/:(nan)/, ":null")
    JSON.parse(payload)
  end
end
