class CallDataRecordObserver < ApplicationObserver
  def call_data_record_created(call_data_record)
    call_data_record.phone_call.complete!
  end
end
