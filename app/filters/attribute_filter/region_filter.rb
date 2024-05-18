module AttributeFilter
  class RegionFilter < ApplicationFilter
    filter_params do
      optional(:region).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(iso_region_code: filter_params.fetch(:region))
    end
  end
end
