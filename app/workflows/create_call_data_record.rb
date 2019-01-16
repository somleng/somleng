class CreateCallDataRecord < ApplicationWorkflow
  attr_accessor :cdr_data

  def initialize(cdr_data)
    self.cdr_data = cdr_data
  end

  def call
    create_call_data_record
  end

  private

  def create_call_data_record
    CallDataRecord.create!(
      phone_call: PhoneCall.find_by(external_id: freeswitch_cdr.uuid),
      file_content_type: freeswitch_cdr.content_type,
      file_filename: freeswitch_cdr.filename,
      file: freeswitch_cdr.io,
      hangup_cause: freeswitch_cdr.hangup_cause,
      direction: freeswitch_cdr.direction,
      duration_sec: freeswitch_cdr.duration_sec,
      bill_sec: freeswitch_cdr.bill_sec,
      start_time: freeswitch_cdr.start_time,
      end_time: freeswitch_cdr.end_time,
      answer_time: freeswitch_cdr.answer_time,
      sip_term_status: freeswitch_cdr.sip_term_status,
      sip_invite_failure_status: freeswitch_cdr.sip_invite_failure_status,
      sip_invite_failure_phrase: freeswitch_cdr.sip_invite_failure_phrase,
      price: 0
    )
  end

  def freeswitch_cdr
    @freeswitch_cdr ||= FreeswitchCDR.new(cdr_data)
  end
end
