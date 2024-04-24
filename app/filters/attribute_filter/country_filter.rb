module AttributeFilter
  class CountryFilter < ApplicationFilter
    filter_params do
      optional(:country).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(options.fetch(:attribute_name, :iso_country_code) => filter_params.fetch(:country))
    end
  end
end
