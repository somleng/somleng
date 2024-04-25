module AttributeFilter
  class EnabledFilter < ApplicationFilter
    filter_params do
      optional(:enabled).value(:bool)
    end

    def apply
      return super if filter_params.blank?

      super.where(enabled: filter_params.fetch(:enabled))
    end
  end
end
