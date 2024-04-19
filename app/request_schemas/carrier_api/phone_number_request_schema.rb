module CarrierAPI
  class PhoneNumberRequestSchema < CarrierAPIRequestSchema
    option :phone_number_parser, default: -> { PhoneNumberParser.new }

    params do
      required(:data).value(:hash).schema do
        optional(:id).filled(:str?)
        required(:type).filled(:str?, eql?: "phone_number")
        optional(:attributes).value(:hash).schema do
          optional(:number).value(ApplicationRequestSchema::Types::Number, :filled?)
          optional(:enabled).filled(:bool?)
          optional(:country).filled(:str?, included_in?: ISO3166::Country.all.map(&:alpha2))
        end

        optional(:relationships).value(:hash).schema do
          required(:account).value(:hash).schema do
            required(:data).value(:hash).schema do
              required(:type).filled(:str?, eql?: "account")
              required(:id).filled(:str?)
            end
          end
        end
      end
    end

    attribute_rule(:number) do
      if resource.present?
        key.failure("cannot be updated") if key? && resource.number != value
      elsif key?
        key.failure("already exists") if carrier.phone_numbers.exists?(number: value)
      else
        key.failure("is missing")
      end
    end

    attribute_rule(:country) do |attributes, context:|
      next if attributes.blank?
      next if resource.blank? && attributes[:number].blank?

      phone_number = phone_number_parser.parse(attributes.fetch(:number) { resource.number })

      if attributes.key?(:country)
        country = ISO3166::Country.new(attributes.fetch(:country))
        context[:country] = country if phone_number.country_code.blank? || country.in?(phone_number.possible_countries)
      else
        context[:country] = if phone_number.country_code.present?
          ResolvePhoneNumberCountry.call(phone_number, fallback_country: carrier.country)
        else
          carrier.country
        end
      end

      key.failure("is invalid") unless context.key?(:country)
    end

    relationship_rule(:account) do
      next unless key?

      account = carrier.accounts.find_by(id: value)
      if account.blank?
        key.failure("does not exist")
      elsif resource&.assigned?
        key.failure("cannot be updated") if resource.account != account
      end
    end

    def output
      params = super

      result = {}
      result[:carrier] = params.fetch(:carrier)
      result[:number] = params.fetch(:number) if params.key?(:number)
      result[:enabled] = params.fetch(:enabled) if params.key?(:enabled)
      result[:account] = Account.find(params.fetch(:account)) if params.key?(:account)
      result[:iso_country_code] = context.fetch(:country).alpha2 if context.key?(:country)
      result
    end
  end
end
