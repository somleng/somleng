module ResponseSchema
  module API
    module Usage
      RecordSchema = Dry::Validation.Schema do
        required(:category).filled(:str?)
        required(:count).filled(:str?)
        required(:price_unit).filled(eql?: "usd")
        required(:subresource_uris).maybe(:hash?)
        required(:description).filled(:str?)
        required(:end_date).filled(:str?)
        required(:usage_unit).filled(:str?)
        required(:price).filled(:str?)
        required(:uri).filled(:str?)
        required(:account_sid).filled(:str?)
        required(:usage).filled(:str?)
        required(:start_date).filled(:str?)
        required(:count_unit).filled(:str?)
      end
    end
  end
end
