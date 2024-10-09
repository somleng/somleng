module AttributeFilter
  class LATAAndRateCenterFilter < ApplicationFilter
    filter_params do
      optional(:lata).value(:string)
      optional(:rate_center).value(:string)
    end

    def apply
      return super if filter_params.blank?
      return super if filter_params[:rate_center].present? && filter_params[:lata].blank?

      filter = {}
      filter[:lata] = filter_params.fetch(:lata) if filter_params.key?(:lata)
      filter[:rate_center] = filter_params.fetch(:rate_center) if filter_params.key?(:rate_center)

      super.where(filter)
    end
  end
end
