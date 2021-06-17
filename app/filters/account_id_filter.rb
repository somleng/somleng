class AccountIdFilter < ApplicationFilter
  filter_params do
    optional(:account_id).value(:string)
  end

  def apply
    return super if filter_params.blank?

    super.where(account_id: filter_params.fetch(:account_id))
  end
end
