class BalanceTransactionFilter < ResourceFilter
  class TypeFilter < ApplicationFilter
    filter_params do
      optional(:type).value(:string, included_in?: BalanceTransaction.type.values)
    end

    def apply
      return super if filter_params.blank?

      super.where(type: filter_params.fetch(:type))
    end
  end

  class ChargeCategoryFilter < ApplicationFilter
    filter_params do
      optional(:charge_category).value(:string, included_in?: BalanceTransaction.charge_category.values)
    end

    def apply
      return super if filter_params.blank?

      super.where(charge_category: filter_params.fetch(:charge_category))
    end
  end

  filter_with(
    TypeFilter,
    ChargeCategoryFilter,
    :id_filter,
    :account_id_filter,
    :date_filter
  )
end
