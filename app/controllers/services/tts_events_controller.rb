module Services
  class TTSEventsController < ServicesController
    def create
      validate_request_schema(
        with: TTSEventRequestSchema,
        location: nil,
      ) do |permitted_params|
        TTSEvent.create!(permitted_params)
      end
    end

    private

    def respond_with_resource(*)
      head(:created)
    end
  end
end
