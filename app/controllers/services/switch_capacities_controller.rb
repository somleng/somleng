module Services
  class SwitchCapacitiesController < ServicesController
    def create
      validate_request_schema(
        with: SwitchCapacityRequestSchema,
        location: nil,
      ) do |permitted_params|
        UpdateSwitchCapacity.call(permitted_params, logger:)
      end
    end

    private

    def respond_with_resource(*)
      head(:ok)
    end
  end
end
