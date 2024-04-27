module APIResponseSchema
  module CarrierAPI
    PhoneNumberSchema = Dry::Schema.JSON do
      required(:id).filled(:str?)
      required(:type).filled(eql?: "phone_number")

      required(:attributes).schema do
        required(:number).filled(:str?)
        required(:visibility).filled(:str?, included_in?: PhoneNumber.visibility.values)
        required(:country).filled(:str?, included_in?: ISO3166::Country.all.map(&:alpha2))
        required(:type).filled(:str?, included_in?: PhoneNumber.type.values)
        required(:price).filled(:str?)
        required(:currency).filled(:str?)
        required(:created_at).filled(:str?)
        required(:updated_at).filled(:str?)
      end
    end
  end
end
