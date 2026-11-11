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

  class MessagingServiceIDFilter < ApplicationFilter
    filter_params do
      optional(:messaging_service_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.joins(
        :messaging_service_alphanumeric_sender_ids
      ).where(
        messaging_service_alphanumeric_sender_ids: {
          messaging_service_id: filter_params.fetch(:messaging_service_id)
        }
      )
    end
  end

  filter_with(
    SenderIDFilter,
    StatusFilter,
    MessagingServiceIDFilter,
    :id_filter,
    :date_filter,
    :account_id_filter
  )
end
