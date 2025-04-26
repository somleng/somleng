module Services
  class CallDataRecordsController < ServicesController
    def create
      payload = Base64.encode64(
        ActiveSupport::Gzip.compress(
          request.raw_post
        )
      )
      ExecuteWorkflowJob.perform_later(ProcessCDR.to_s, payload)
      head(:no_content)
    end
  end
end
