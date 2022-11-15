module APIResponseSchema
  module TwilioAPI
    MessageSchema = Dry::Schema.Params do
      required(:account_sid).maybe(:str?)
      required(:api_version).filled(:str?, eql?: "2010-04-01")
      required(:body).maybe(:str?)
      required(:date_created).maybe(:str?)
      required(:date_sent).maybe(:str?)
      required(:date_updated).maybe(:str?)
      required(:direction).filled(:str?, included_in?: %w[inbound outbound-api])
      required(:error_code).maybe(:str?)
      required(:error_message).maybe(:str?)
      required(:from).filled(:str?)
      required(:messaging_service_sid).maybe(:str?)
      required(:num_media).maybe(:str?)
      required(:num_segments).maybe(:str?)
      required(:price).maybe(:str?)
      required(:price_unit).maybe(:str?)
      required(:sid).maybe(:str?)
      required(:status).filled(:str?)
      required(:subresource_uris).maybe(:hash?, eql?: {})
      required(:tags).maybe(:hash?, eql?: {})
      required(:to).filled(:str?)
      required(:uri).filled(:str?)
    end
  end
end
