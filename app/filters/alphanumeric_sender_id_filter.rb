class AlphanumericSenderIDFilter < ResourceFilter
  class SenderIDFilter < ApplicationFilter
    filter_params do
      optional(:sender_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      FuzzySearch.new(super, column: :sender_id).apply(filter_params.fetch(:sender_id))
    end
  end

  filter_with(
    SenderIDFilter,
    :id_filter,
    :date_filter,
    :account_id_filter
  )
end
