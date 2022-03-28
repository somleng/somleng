module APIResponseSchema
  module TwilioAPI
    RecordingSchema = Dry::Schema.Params do
      required(:account_sid).filled(:str?)
      required(:api_version).filled(:str?, eql?: "2010-04-01")
      required(:call_sid).filled(:str?)
      required(:conference_sid).maybe(:str?)
      required(:channels).filled(:int?)
      required(:start_time).filled(:str?)
      required(:price).maybe(:str?)
      required(:price_unit).maybe(:str?)
      required(:duration).maybe(:str?)
      required(:sid).filled(:str?)
      required(:source).filled(:str?)
      required(:status).filled(:str?)
      required(:error_code).maybe(:str?)
      required(:encryption_details).maybe(:str?)
      required(:track).filled(:str?)
      required(:date_created).filled(:str?)
      required(:date_updated).filled(:str?)
      required(:uri).filled(:str?, format?: /Recordings/)
    end
  end
end
