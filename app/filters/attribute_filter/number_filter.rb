module AttributeFilter
  class NumberFilter < ApplicationFilter
    filter_params do
      optional(:number).value(ApplicationRequestSchema::Types::Number)
    end

    def apply
      return super if filter_params.blank?

      super.where(number: filter_params.fetch(:number))
    end
  end
end
