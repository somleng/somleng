module AttributeFilter
  class ToFilter < ApplicationFilter
    filter_params do
      optional(:to).value(ApplicationRequestSchema::Types::Number)
    end

    def apply
      return super if filter_params.blank?

      super.where(to: filter_params.fetch(:to))
    end
  end
end
