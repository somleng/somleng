module CarrierAPI
  class PhoneNumberRequestSchema < CarrierAPIRequestSchema
    option :phone_number_country_assignment_rules, default: -> { PhoneNumberCountryAssignmentRules.new }

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
          required(:account).filled(:hash).schema do
            required(:data).filled(:hash).schema do
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

      context[:country] = phone_number_country_assignment_rules.assign_country(
        number: attributes.fetch(:number) { resource.number },
        preferred_country: ISO3166::Country.new(attributes[:country]),
        fallback_country: carrier.country,
        existing_country: resource&.country
      )

      key.failure("is invalid") if context[:country].blank?
    end


    rule(data: { relationships: { account: { data: :id } } }) do |context:|
      next unless key?

      context[:account] = carrier.accounts.find_by(id: value)
      if context.fetch(:account).blank?
        key.failure("does not exist")
      elsif resource&.assigned?
        key.failure("cannot be updated") if resource.account != context.fetch(:account)
      end
    end

    def output
      params = super

      result = {}
      result[:carrier] = params.fetch(:carrier)
      result[:number] = params.fetch(:number) if params.key?(:number)
      result[:enabled] = params.fetch(:enabled) if params.key?(:enabled)
      result[:account] = context.fetch(:account) if context[:account].present?
      result[:iso_country_code] = context.fetch(:country).alpha2 if context[:country].present?
      result
    end
  end
end
