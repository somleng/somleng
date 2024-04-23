class PhoneNumberFilter < ResourceFilter
  class CountryFilter < ApplicationFilter
    filter_params do
      optional(:country).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(iso_country_code: filter_params.fetch(:country))
    end
  end

  class TypeFilter < ApplicationFilter
    filter_params do
      optional(:type).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(type: filter_params.fetch(:type))
    end
  end

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
        super.where.not(account_id: nil)
      else
        super.where(account_id: nil)
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
    CountryFilter,
    TypeFilter,
    EnabledFilter,
    AssignedFilter,
    UtilizedFilter,
    ConfiguredFilter,
    AccountIDFilter,
    :date_filter
  )
end
