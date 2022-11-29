module CarrierAPI
  module SchemaRules
    class UpdateInteraction
      CURRENCIES = Money::Currency.table.values.pluck(:iso_code)

      def validate(attributes, context:)
        validate_price(attributes, context:)
        validate_price_unit(attributes, context:)
      end

      private

      def validate_price(attributes, context:)
        return unless attributes.values_at(:price, :price_unit).one?

        key(context, :price).failure(text: "is blank") unless attributes.key?(:price)
        key(context, :price_unit).failure(text: "is blank") unless attributes.key?(:price_unit)
      end

      def validate_price_unit(attributes, context:)
        return unless attributes.key?(:price_unit)
        return if CURRENCIES.include?(attributes.fetch(:price_unit))

        key(context, :price_unit).failure("must be one of ISO 4217 currency format")
      end

      def key(context, *path)
        context.key(context.attribute_key_path(*path))
      end
    end
  end
end
