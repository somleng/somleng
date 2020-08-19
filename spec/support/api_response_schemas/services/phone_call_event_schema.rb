module APIResponseSchema
  module Services
    PhoneCallEventSchema = Dry::Schema.Params do
      required(:type).filled(:str?)
      required(:api_version).filled(:str?, eql?: "2010-04-01")
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end
  end
end
