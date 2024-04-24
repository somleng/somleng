module AttributeFilter
  class CurrencyFilter < ApplicationFilter
    filter_params do
      optional(:currency).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(currency: filter_params.fetch(:currency))
    end
  end
end
