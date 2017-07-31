class Api::Admin::CallDataRecordsController < Api::Admin::BaseController
  def create
    enqueue_process!(request.raw_post)
    head(:created)
  end

  private

  def enqueue_process!(cdr)
    job_adapter.perform_later(cdr)
  end

  def job_adapter
    @job_adapter ||= JobAdapter.new(:call_data_record_worker)
  end

  def permission_name
    :manage_call_data_records
  end
end
