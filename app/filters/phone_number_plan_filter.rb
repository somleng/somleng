class PhoneNumberPlanFilter < ResourceFilter
  class StatusFilter < ApplicationFilter
    filter_params do
      optional(:status).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(status: filter_params.fetch(:status))
    end
  end

  class NumberFilter < ApplicationFilter
    filter_params do
      optional(:number).value(ApplicationRequestSchema::Types::Number)
    end

    def apply
      return super if filter_params.blank?

      super.where(number: filter_params.fetch(:number))
    end
  end

  filter_with(
    StatusFilter,
    NumberFilter,
    :account_id_filter,
    :date_filter
  )
end
