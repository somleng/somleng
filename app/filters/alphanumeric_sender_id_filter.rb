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

  class StatusFilter < ApplicationFilter
    filter_params do
      optional(:status).value(:string, included_in?: AlphanumericSenderID.status.values)
    end

    def apply
      return super if filter_params.blank?

      super.where(status: filter_params.fetch(:status))
    end
  end

  filter_with(
    SenderIDFilter,
    StatusFilter,
    :id_filter,
    :date_filter,
    :account_id_filter
  )
end
