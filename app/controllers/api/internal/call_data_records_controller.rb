class Api::Internal::CallDataRecordsController < Api::Internal::BaseController
  def create
    enqueue_process!(request.raw_post)
    head(:created)
  end

  private

  def enqueue_process!(cdr)
    CallDataRecordJob.perform_later(cdr)
  end

  def permission_name
    :manage_call_data_records
  end
end
