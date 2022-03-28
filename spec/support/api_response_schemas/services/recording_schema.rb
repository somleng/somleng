module APIResponseSchema
  module Services
    RecordingSchema = Dry::Schema.Params do
      required(:sid).filled(:str?)
      required(:duration).maybe(:str?)
      required(:url).filled(:str?)
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end
  end
end
