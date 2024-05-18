module AttributeFilter
  class LocalityFilter < ApplicationFilter
    filter_params do
      optional(:locality).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(locality: filter_params.fetch(:locality))
    end
  end
end
