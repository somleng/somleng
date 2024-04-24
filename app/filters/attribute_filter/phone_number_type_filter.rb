module AttributeFilter
  class PhoneNumberTypeFilter < ApplicationFilter
    filter_params do
      optional(:type).value(:string, included_in?: PhoneNumber.type.values)
    end

    def apply
      return super if filter_params.blank?

      super.where(type: filter_params.fetch(:type))
    end
  end
end
