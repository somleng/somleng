class AccountFilter < ResourceFilter
  class StatusFilter < ApplicationFilter
    filter_params do
      optional(:status).value(:string, included_in?: Account.status.values)
    end

    def apply
      return super if filter_params.blank?

      super.where(status: filter_params.fetch(:status))
    end
  end

  class TypeFilter < ApplicationFilter
    filter_params do
      optional(:type).value(:string, included_in?: Account::TYPES)
    end

    def apply
      return super if filter_params.blank?

      case filter_params.fetch(:type)
      when "carrier_managed"
        super.merge(Account.carrier_managed)
      when "customer_managed"
        super.merge(Account.customer_managed)
      end
    end
  end

  filter_with StatusFilter, TypeFilter, DateFilter
end
