class MessagingServiceFilter < ResourceFilter
  class AlphanumericSenderIDIDFilter < ApplicationFilter
    filter_params do
      optional(:alphanumeric_sender_id_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.joins(
        :messaging_service_alphanumeric_sender_ids
      ).where(
        messaging_service_alphanumeric_sender_ids: {
          sender_id_id: filter_params.fetch(:alphanumeric_sender_id_id)
        }
      )
    end
  end

  filter_with(
    AlphanumericSenderIDIDFilter,
    :account_id_filter,
    :name_filter
  )
end
