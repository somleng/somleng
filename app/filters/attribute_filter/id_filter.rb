module AttributeFilter
  class IDFilter < ApplicationFilter
    filter_params do
      optional(:id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(id: filter_params.fetch(:id))
    end
  end
end
