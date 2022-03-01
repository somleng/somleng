module APIResponseSchema
  module Services
    RecordingSchema = Dry::Schema.Params do
      required(:sid).filled(:str?)
      required(:account_sid).filled(:str?)
      required(:status).filled(:str?)
      required(:external_id).maybe(:str?)
      required(:duration).maybe(:int?)
      required(:url).filled(:str?)
      required(:api_version).filled(:str?, eql?: "2010-04-01")
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end
  end
end
