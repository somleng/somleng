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

  filter_with(
    TypeFilter,
    :id_filter,
    :account_id_filter,
    :date_filter
  )
end
