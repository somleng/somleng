module Services
  class CallDataRecordsController < ServicesController
    def create
      ProcessCDRJob.perform_later(request.request_parameters)
      head(:no_content)
    end
  end
end
