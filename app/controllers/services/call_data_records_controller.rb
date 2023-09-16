module Services
  class CallDataRecordsController < ServicesController
    def create
      payload = Base64.encode64(
        ActiveSupport::Gzip.compress(
          request.request_parameters.to_json
        )
      )
      ExecuteWorkflowJob.perform_later(ProcessCDR.to_s, payload)
      head(:no_content)
    end
  end
end
