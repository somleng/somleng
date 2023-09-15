module Services
  class UpdateRecordingRequestSchema < ServicesRequestSchema
    option :url_validator, default: proc { URLValidator.new }

    params do
      required(:raw_recording_url).filled(:str?)
      required(:external_id).filled(:str?)
    end

    rule(:raw_recording_url) do
      next if url_validator.valid?(value)

      key(:raw_recording_url).failure("is invalid")
    end
  end
end
