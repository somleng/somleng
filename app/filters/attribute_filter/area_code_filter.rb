module AttributeFilter
  class AreaCodeFilter < ApplicationFilter
    filter_params do
      optional(:area_code).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(area_code: filter_params.fetch(:area_code))
    end
  end
end
