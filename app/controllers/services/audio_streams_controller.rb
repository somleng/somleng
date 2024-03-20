module Services
  class AudioStreamsController < ServicesController
    def create
      validate_request_schema(
        with: AudioStreamRequestSchema,
        serializer_class: AudioStreamSerializer,
        location: nil
      ) do |permitted_params|
        AudioStream.create!(permitted_params)
      end
    end
  end
end
