class PhoneNumberPlanFilter < ResourceFilter
  class StatusFilter < ApplicationFilter
    filter_params do
      optional(:status).value(:string, included_in?: PhoneNumberPlan.status.values)
    end

    def apply
      return super if filter_params.blank?

      super.where(status: filter_params.fetch(:status))
    end
  end

  filter_with(
    StatusFilter,
    :number_filter,
    :account_id_filter,
    :date_filter
  )
end
