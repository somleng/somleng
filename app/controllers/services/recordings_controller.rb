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


    def update
      recording = Recording.find(params[:id])

      validate_request_schema(
        with: UpdateRecordingRequestSchema,
        serializer_class: RecordingSerializer,
        schema_options: { resource: recording }
      ) do |permitted_params|
        recording.update!(permitted_params)
        ExecuteWorkflowJob.perform_later(ProcessRecording.to_s, recording)

        recording
      end
    end
  end
end
