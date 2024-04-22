module CarrierAPI
  class PhoneNumberRequestSchema < CarrierAPIRequestSchema
    TypeValidator = Struct.new(:number, :type, keyword_init: true) do
      include ActiveModel::Validations

      def self.model_name
        ActiveModel::Name.new(self, nil, name.to_s)
      end

      validates :type, phone_number_type: true
    end

    CurrencyValidator = Struct.new(:currency, keyword_init: true) do
      include ActiveModel::Validations

      def self.model_name
        ActiveModel::Name.new(self, nil, name.to_s)
      end

      validates :currency, currency: true
    end

    option :phone_number_country_assignment_rules, default: -> { PhoneNumberCountryAssignmentRules.new }
    option :type_validator, default: -> { TypeValidator.new }
    option :currency_validator, default: -> { CurrencyValidator.new }

    params do
      required(:data).value(:hash).schema do
        optional(:id).filled(:str?)
        required(:type).filled(:str?, eql?: "phone_number")
        optional(:attributes).value(:hash).schema do
          optional(:number).value(ApplicationRequestSchema::Types::Number, :filled?)
          optional(:enabled).filled(:bool?)
          optional(:type).filled(:str?, included_in?: PhoneNumber.type.values)
          optional(:country).filled(:str?, included_in?: ISO3166::Country.all.map(&:alpha2))
          optional(:price).filled(:decimal, gteq?: 0)
          optional(:currency).filled(:str?, included_in?: ::CurrencyValidator::VALID_CURRENCIES.map(&:iso_code))
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

      context[:country] = phone_number_country_assignment_rules.country_for(
        number: attributes.fetch(:number) { resource.number },
        preferred_country: ISO3166::Country.new(attributes[:country]),
        fallback_country: carrier.country,
        existing_country: resource&.country
      )

      key.failure("is invalid") if context[:country].blank?
    end

    attribute_rule(:type) do |attributes|
      next unless key?
      next if resource.blank? && attributes[:number].blank?

      type_validator.number = attributes.fetch(:number) { resource.number }
      type_validator.type = value

      next if type_validator.valid?
      next if type_validator.errors[:type].blank?

      key.failure(type_validator.errors[:type].to_sentence)
    end

    attribute_rule(:price, :currency) do |attributes, context:|
      if attributes.blank? || (!attributes.key?(:price) && !attributes.key?(:currency))
        context[:price] = Money.new(0, carrier.billing_currency) if resource.blank?
        next
      end

      next key(attribute_key_path(:currency)).failure("is missing") if !attributes.key?(:currency)
      next key(attribute_key_path(:price)).failure("is missing") if !attributes.key?(:price)
      next key(attribute_key_path(:currency)).failure("is invalid") if (resource.present? ? resource.currency : carrier.billing_currency) != attributes.fetch(:currency)

      context[:price] = Money.from_amount(attributes.fetch(:price), attributes.fetch(:currency))
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
      result[:type] = params.fetch(:type) if params.key?(:type)
      result[:iso_country_code] = context.fetch(:country).alpha2 if context[:country].present?
      result[:price] = context.fetch(:price) if context.key?(:price)
      result
    end
  end
end
