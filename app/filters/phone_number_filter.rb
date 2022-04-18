class PhoneNumberFilter < ResourceFilter
  class AccountFilter < ApplicationFilter
    filter_params do
      optional(:account_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(account_id: filter_params.fetch(:account_id))
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

  filter_with AccountFilter, EnabledFilter, DateFilter, AssignedFilter
end
