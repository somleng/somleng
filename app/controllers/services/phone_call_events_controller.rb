module Services
  class PhoneCallEventsController < ServicesController
    def create
      validate_request_schema(
        with: PhoneCallEventRequestSchema,
        location: nil
      ) do |permitted_params|
        ExecuteWorkflowJob.perform_later(
          "ProcessPhoneCallEvent",
          permitted_params
        )
      end
    end

    private

    def respond_with_resource(*)
      head(:created)
    end
  end
end
