class Api::Admin::CallDataRecordsController < Api::Admin::BaseController
  def create
    CallDataRecord.new.enqueue_process!(request.raw_post)
    head(:created)
  end

  private

  def permission_name
    :manage_call_data_records
  end
end
