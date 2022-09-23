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

  class ToFilter < ApplicationFilter
    filter_params do
      optional(:to).value(ApplicationRequestSchema::Types::Number)
    end

    def apply
      return super if filter_params.blank?

      super.where(to: filter_params.fetch(:to))
    end
  end

  class FromFilter < ApplicationFilter
    filter_params do
      optional(:from).value(ApplicationRequestSchema::Types::Number)
    end

    def apply
      return super if filter_params.blank?

      super.where(from: filter_params.fetch(:from))
    end
  end

  def apply
    return super unless scoped_to.key?(:carrier_id)

    carrier_id = scoped_to.delete(:carrier_id)
    super.joins(:account).where(accounts: { carrier_id: carrier_id })
  end

  filter_with IDFilter, AccountFilter, ToFilter, FromFilter, DateFilter
end
