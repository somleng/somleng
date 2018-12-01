module ResponseSchema
  module API
    PhoneCallSchema = Dry::Validation.Schema do
      required(:account_sid).filled(:str?)
      required(:annotation).maybe(:str?)
      required(:answered_by).maybe(:str?)
      required(:api_version).filled(eql?: "2010-04-01")
      required(:caller_name).maybe(:str?)
      required(:date_created).filled(:str?)
      required(:date_updated).filled(:str?)
      required(:direction).filled(:str?)
      required(:duration).maybe(:int?)
      required(:end_time).maybe(:str?)
      required(:forwarded_from).maybe(:str?)
      required(:from).filled(:str?)
      required(:from_formatted).filled(:str?)
      required(:group_sid).maybe(:str?)
      required(:parent_call_sid).maybe(:str?)
      required(:phone_number_sid).maybe(:str?)
      required(:price).maybe(:str?)
      required(:price_unit).filled(eql?: "USD")
      required(:sid).filled(:str?)
      required(:start_time).maybe(:str?)
      required(:status).filled(:str?)
      required(:subresource_uris).filled(:hash?)
      required(:to).filled(:str?)
      required(:to_formatted).filled(:str?)
      required(:uri).filled(:str?)
    end
  end
end
