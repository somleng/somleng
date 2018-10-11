class CallDataRecordJob < ApplicationJob
  attr_accessor :raw_cdr

  def perform(raw_cdr)
    self.raw_cdr = raw_cdr
    subscribe_listeners
    process_raw_cdr
    call_data_record.save
    call_data_record
  end

  private

  def call_data_record
    @call_data_record ||= CallDataRecord.new
  end

  def subscribe_listeners
    call_data_record.subscribe(CallDataRecordObserver.new)
  end

  def process_raw_cdr
    freeswitch_cdr = CDR::Freeswitch.new(raw_cdr)
    call_data_record.phone_call = PhoneCall.find_by_external_id(freeswitch_cdr.uuid)
    call_data_record.file_content_type, call_data_record.file_filename, call_data_record.file = freeswitch_cdr.to_file
    call_data_record.hangup_cause = freeswitch_cdr.hangup_cause
    call_data_record.direction = freeswitch_cdr.direction
    call_data_record.duration_sec = freeswitch_cdr.duration_sec
    call_data_record.bill_sec = freeswitch_cdr.bill_sec
    call_data_record.start_time = parse_epoch(freeswitch_cdr.start_epoch)
    call_data_record.end_time = parse_epoch(freeswitch_cdr.end_epoch)
    call_data_record.answer_time = parse_epoch(freeswitch_cdr.answer_epoch)
    call_data_record.sip_term_status = freeswitch_cdr.sip_term_status
    call_data_record.sip_invite_failure_status = freeswitch_cdr.sip_invite_failure_status
    call_data_record.sip_invite_failure_phrase = freeswitch_cdr.sip_invite_failure_phrase
    call_data_record.price = 0
  end

  def parse_epoch(epoch)
    epoch = epoch.to_i
    Time.at(epoch) if epoch > 0
  end
end
