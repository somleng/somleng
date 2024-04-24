class PhoneNumberFilter < ResourceFilter
  class EnabledFilter < ApplicationFilter
    filter_params do
      optional(:enabled).value(:bool)
    end

    def apply
      return super if filter_params.blank?

      super.where(enabled: filter_params.fetch(:enabled))
    end
  end

  class AssignedFilter < ApplicationFilter
    filter_params do
      optional(:assigned).value(:bool)
    end

    def apply
      return super if filter_params.blank?

      if filter_params.fetch(:assigned)
        super.assigned
      else
        super.unassigned
      end
    end
  end

  class UtilizedFilter < ApplicationFilter
    filter_params do
      optional(:utilized).value(:bool)
    end

    def apply
      return super if filter_params.blank?

      if filter_params.fetch(:utilized)
        super.utilized
      else
        super.unutilized
      end
    end
  end

  class ConfiguredFilter < ApplicationFilter
    filter_params do
      optional(:configured).value(:bool)
    end

    def apply
      return super if filter_params.blank?

      if filter_params.fetch(:configured)
        super.configured
      else
        super.unconfigured
      end
    end
  end

  class AccountIDFilter < ApplicationFilter
    filter_params do
      optional(:account_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.joins(:active_plan).where(phone_number_plans: { account_id: filter_params.fetch(:account_id) })
    end
  end

  filter_with(
    EnabledFilter,
    AssignedFilter,
    UtilizedFilter,
    ConfiguredFilter,
    AccountIDFilter,
    :phone_number_type_filter,
    { country_filter: { attribute_name: :iso_country_code } },
    :number_filter,
    :date_filter
  )
end
