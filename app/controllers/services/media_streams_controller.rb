module Services
  class MediaStreamsController < ServicesController
    def create
      validate_request_schema(
        with: MediaStreamRequestSchema,
        serializer_class: MediaStreamSerializer,
        location: nil
      ) do |permitted_params|
        MediaStream.create!(permitted_params)
      end
    end
  end
end
