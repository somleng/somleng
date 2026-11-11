class IncomingPhoneNumberFilter < ResourceFilter
  class StatusFilter < ApplicationFilter
    filter_params do
      optional(:status).value(:string, included_in?: IncomingPhoneNumber.status.values)
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

      super.where(messaging_service_id: filter_params.fetch(:messaging_service_id))
    end
  end

  filter_with(
    StatusFilter,
    MessagingServiceIDFilter,
    :number_filter,
    :account_id_filter,
    { date_filter: { timestamp_column: :created_at } }
  )
end
