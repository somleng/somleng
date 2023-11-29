module AttributeFilter
  class PhoneCallIDFilter < ApplicationFilter
    filter_params do
      optional(:phone_call_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(phone_call_id: filter_params.fetch(:phone_call_id))
    end
  end
end
