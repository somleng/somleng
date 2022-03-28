module Services
  class UpdateRecordingRequestSchema < ServicesRequestSchema
    params do
      required(:raw_recording_url).filled(:str?, format?: URL_FORMAT)
      required(:external_id).filled(:str?)
      required(:duration).value(:integer, :filled?)
    end
  end
end
