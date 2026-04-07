module Services
  class CallHeartbeatsController < ServicesController
    def create
      validate_request_schema(with: CallHeartbeatsRequestSchema) do |permitted_params|
        HandleCallHeartbeats.call(permitted_params.fetch(:call_ids))
      end
    end

    private

    def respond_with_resource(*)
      head(:no_content)
    end
  end
end
