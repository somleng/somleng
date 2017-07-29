class Api::Admin::CallDataRecordsController < Api::Admin::BaseController
  def create
    subscribe_listeners
    CallDataRecord.new.enqueue_process!(request.raw_post)
    head(:created)
  end

  private

  def subscribe_listeners
    Wisper.subscribe(CallDataRecordObserver.new)
  end

  def permission_name
    :manage_call_data_records
  end
end
