module Services
  class RecordingsController < ServicesController
    def create
      validate_request_schema(
        with: RecordingRequestSchema,
        serializer_class: RecordingSerializer,
        location: nil
      ) do |permitted_params|
        Recording.create!(permitted_params)
      end
    end
  end
end
