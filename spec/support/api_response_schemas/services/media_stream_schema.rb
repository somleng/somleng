module APIResponseSchema
  module Services
    MediaStreamSchema = Dry::Schema.Params do
      required(:sid).filled(:str?)
      required(:url).filled(:str?)
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end
  end
end
