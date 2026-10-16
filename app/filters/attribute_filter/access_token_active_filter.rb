module AttributeFilter
  class AccessTokenActiveFilter < ApplicationFilter
    filter_params do
      optional(:active).value(:bool)
    end

    def apply
      return super if filter_params.blank?

      filter_params.fetch(:active) ? super.active : super.revoked
    end
  end
end
