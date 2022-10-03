class ProcessCDRJob < ApplicationJob
  def perform(cdr)
    call_data_record = create_call_data_record(cdr)
    return unless call_data_record.call_leg.A?

    update_phone_call_status(call_data_record.phone_call)
    notify_status_callback_url(call_data_record.phone_call)
    create_event(call_data_record.phone_call)
  end

  private

  def create_call_data_record(cdr)
    cdr_variables = cdr.fetch("variables")
    phone_call = find_phone_call(cdr_variables)

    CallDataRecord.create!(
      phone_call:,
      call_leg: call_leg_B?(cdr) ? "B" : "A",
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

  def call_leg_B?(cdr)
    cdr.fetch("callflow").any? { |callflow| callflow.dig("caller_profile", "originatee").present? }
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

    ExecuteWorkflowJob.perform_later(
      "NotifyPhoneCallStatusCallback", phone_call
    )
  end

  def create_event(phone_call)
    CreateEvent.call(eventable: phone_call, type: "phone_call.completed")
  end

  def parse_epoch(epoch)
    epoch = epoch.to_i
    Time.at(epoch) if epoch.positive?
  end

  def find_phone_call(cdr_variables)
    phone_call_id = cdr_variables["sip_rh_X-Somleng-CallSid"]
    phone_call_id ||= cdr_variables["sip_h_X-Somleng-CallSid"]

    return PhoneCall.find(phone_call_id) if phone_call_id.present?

    PhoneCall.find_by!(external_id: cdr_variables.fetch("uuid"))
  end
end
