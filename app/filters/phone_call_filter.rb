class PhoneCallFilter < ResourceFilter
  class AccountFilter < ApplicationFilter
    filter_params do
      optional(:account_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(account_id: filter_params.fetch(:account_id))
    end
  end

  def apply
    return super unless scoped_to.key?(:carrier_id)

    carrier_id = scoped_to.delete(:carrier_id)
    super.joins(:account).where(accounts: { carrier_id: carrier_id })
  end

  filter_with AccountFilter, DateFilter
end
