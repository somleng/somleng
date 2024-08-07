module APIResponseSchema
  module TwilioAPI
    CallSchema = Dry::Schema.Params do
      required(:annotation).maybe(:str?)
      required(:parent_call_sid).maybe(:str?)
      required(:answered_by).maybe(:str?)
      required(:caller_name).maybe(:str?)
      required(:direction).filled(:str?, included_in?: %w[inbound outbound-api outbound-dial])
      required(:duration).maybe(:str?)
      required(:end_time).maybe(:str?)
      required(:forwarded_from).maybe(:str?)
      required(:from).filled(:str?)
      required(:from_formatted).filled(:str?)
      required(:group_sid).maybe(:str?)
      required(:parent_call_sid).maybe(:str?)
      required(:phone_number_sid).maybe(:str?)
      required(:price).maybe(:str?)
      required(:price_unit).maybe(:str?)
      required(:end_time).maybe(:str?)
      required(:status).filled(:str?)
      required(:subresource_uris).maybe(:hash?, eql?: {})
      required(:to).filled(:str?)
      required(:to_formatted).filled(:str?)
      required(:api_version).filled(:str?, eql?: "2010-04-01")
      required(:date_created).filled(:str?)
      required(:date_updated).filled(:str?)
      required(:uri).filled(:str?)
    end
  end
end
