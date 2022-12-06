module CarrierAPI
  class PhoneCallFilterRequestSchema < ApplicationRequestSchema
    option :interaction_filter,
           default: -> { SchemaRules::InteractionFilter.new(decorator_class: PhoneCallDecorator) }

    params do
      optional(:filter).value(:hash).hash do
        optional(:account).filled(:string)
        optional(:from_date).value(:time)
        optional(:to_date).value(:time)
        optional(:direction).filled(
          :str?, included_in?: PhoneCallDecorator.directions
        )
        optional(:status).filled(
          :str?, included_in?: PhoneCallDecorator.statuses
        )
      end
    end

    rule(:filter).validate(:date_range)

    def output
      interaction_filter.output(super.fetch(:filter, {}))
    end
  end
end
