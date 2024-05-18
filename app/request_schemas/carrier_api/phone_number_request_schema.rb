module CarrierAPI
  class PhoneNumberRequestSchema < CarrierAPIRequestSchema
    class TypeValidator
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :number, PhoneNumberType.new
      attribute :type

      def self.model_name
        ActiveModel::Name.new(self, nil, name.to_s)
      end

      validates :type, phone_number_type: true
    end

    class CountryValidator
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :number, PhoneNumberType.new
      attribute :country
      attribute :region

      def self.model_name
        ActiveModel::Name.new(self, nil, name.to_s)
      end

      validates :country, phone_number_country: true, allow_blank: true
      validates :region, country_subdivision: { country_attribute: :country, country_code: ->(record) { record.country } }
    end

    option :type_validator, default: -> { TypeValidator.new }
    option :country_validator, default: -> { CountryValidator.new }

    params do
      required(:data).value(:hash).schema do
        optional(:id).filled(:str?)
        required(:type).filled(:str?, eql?: "phone_number")
        optional(:attributes).value(:hash).schema do
          optional(:number).value(ApplicationRequestSchema::Types::Number, :filled?)
          optional(:visibility).filled(:str?, included_in?: PhoneNumber.visibility.values)
          optional(:type).filled(:str?, included_in?: PhoneNumber.type.values)
          optional(:country).filled(:str?, included_in?: ISO3166::Country.all.map(&:alpha2))
          optional(:price).filled(:decimal, gteq?: 0)
          optional(:region).filled(:str?)
          optional(:locality).filled(:str?)
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

    attribute_rule(:country, :region) do |attributes|
      next if attributes.blank?
      next if resource.blank? && attributes[:number].blank?

      country_validator.number = attributes.fetch(:number) { resource.number }
      country_validator.country = attributes.fetch(:country) { resource&.iso_country_code }
      country_validator.region = attributes[:region]

      next if country_validator.valid?

      if country_validator.errors[:country].present?
        key([ :data, :attributes, :country ]).failure(country_validator.errors[:country].to_sentence)
      elsif country_validator.errors[:region].present?
        key([ :data, :attributes, :region ]).failure(country_validator.errors[:region].to_sentence)
      end
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

    def output
      params = super

      result = {}
      result[:carrier] = params.fetch(:carrier)
      result[:number] = params.fetch(:number) if params.key?(:number)
      result[:visibility] = params.fetch(:visibility) if params.key?(:visibility)
      result[:type] = params.fetch(:type) if params.key?(:type)
      result[:iso_country_code] = params.fetch(:country) if params.key?(:country)
      result[:price] = Money.from_amount(params.fetch(:price), carrier.billing_currency) if params.key?(:price)
      result[:iso_region_code] = params.fetch(:region) if params.key?(:region)
      result[:locality] = params.fetch(:locality) if params.key?(:locality)
      result
    end
  end
end
