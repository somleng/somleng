module AttributeFilter
  class PhoneNumberIDFilter < ApplicationFilter
    filter_params do
      optional(:phone_number_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(options.fetch(:attribute_name, :phone_number_id) => filter_params.fetch(:phone_number_id))
    end
  end
end
