class ErrorLogFilter < ResourceFilter
  class AccountFilter < ApplicationFilter
    filter_params do
      optional(:account_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(account_id: filter_params.fetch(:account_id))
    end
  end

  filter_with AccountFilter, DateFilter
end
