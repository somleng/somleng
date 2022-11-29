module AttributeFilter
  class FromFilter < ApplicationFilter
    filter_params do
      optional(:from).value(ApplicationRequestSchema::Types::Number)
    end

    def apply
      return super if filter_params.blank?

      super.where(from: filter_params.fetch(:from))
    end
  end
end
