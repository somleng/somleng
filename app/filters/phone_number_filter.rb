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

  filter_with AccountFilter, EnabledFilter, DateFilter
end
