module Services
  class CallServiceCapacitiesController < ServicesController
    def create
      validate_request_schema(
        with: CallServiceCapacityRequestSchema,
        location: nil,
      ) do |permitted_params|
        UpdateCallServiceCapacity.call(permitted_params)
      end
    end

    private

    def respond_with_resource(*)
      head(:ok)
    end
  end
end
