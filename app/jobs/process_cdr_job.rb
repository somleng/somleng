class ProcessCDRJob < ApplicationJob
  def perform(cdr)
    call_data_record = create_call_data_record(cdr)
    if call_data_record.call_leg.A?
      update_phone_call_status(call_data_record.phone_call)
      notify_status_callback_url(call_data_record.phone_call)
    end
  end

  private

  def create_call_data_record(cdr)
    cdr_variables = cdr.fetch("variables")
    phone_call_id = call_leg_A?(cdr) ? cdr_variables.fetch("uuid") : cdr_variables.fetch("bridge_uuid")
    phone_call = PhoneCall.find_by!(external_id: phone_call_id)

    CallDataRecord.create!(
      phone_call: phone_call,
      call_leg: call_leg_A?(cdr) ? "A" : "B",
      hangup_cause: cdr_variables.fetch("hangup_cause"),
      direction: cdr_variables.fetch("direction"),
      duration_sec: cdr_variables.fetch("duration"),
      bill_sec: cdr_variables.fetch("billsec"),
      start_time: parse_epoch(cdr_variables.fetch("start_epoch")),
      end_time: parse_epoch(cdr_variables.fetch("end_epoch")),
      answer_time: parse_epoch(cdr_variables.fetch("answer_epoch")),
      sip_term_status: cdr_variables["sip_term_status"],
      sip_invite_failure_status: cdr_variables["sip_invite_failure_status"],
      sip_invite_failure_phrase: URI.decode_www_form_component(
        cdr_variables.fetch("sip_invite_failure_phrase", "")
      ).presence,
      file: {
        io: StringIO.new(cdr.to_json),
        filename: "#{cdr_variables.fetch('uuid')}.json",
        content_type: "application/json"
      }
    )
  end

  def call_leg_A?(cdr)
    return true if cdr.fetch("callflow").one?

    cdr.fetch("callflow").any? { |callflow| callflow.dig("caller_profile", "originator").present? }
  end

  def update_phone_call_status(phone_call)
    UpdatePhoneCallStatus.call(
      phone_call,
      event_type: :completed,
      answer_epoch: phone_call.call_data_record.answer_time.to_i,
      sip_term_status: phone_call.call_data_record.sip_term_status,
      sip_invite_failure_status: phone_call.call_data_record.sip_invite_failure_status
    )
  end

  def notify_status_callback_url(phone_call)
    return if phone_call.status_callback_url.blank?

    StatusCallbackNotifierJob.perform_later(phone_call)
  end

  def parse_epoch(epoch)
    epoch = epoch.to_i
    Time.at(epoch) if epoch.positive?
  end
end
