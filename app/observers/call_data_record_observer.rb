class CallDataRecordObserver < ApplicationObserver
  attr_accessor :call_data_record

  def call_data_record_created(call_data_record)
    self.call_data_record = call_data_record
    subscribe_listeners
    phone_call.complete!
  end

  private

  def phone_call
    @phone_call ||= call_data_record.phone_call
  end

  def subscribe_listeners
    phone_call.subscribe(PhoneCallObserver.new)
  end
end
