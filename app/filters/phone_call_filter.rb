class PhoneCallFilter < ResourceFilter
  class StatusFilter < ApplicationFilter
    filter_params do
      optional(:status).value(:string, included_in?: PhoneCallDecorator.statuses)
    end

    def apply
      return super if filter_params.blank?

      super.where(status: PhoneCallDecorator.status_from(filter_params.fetch(:status)))
    end
  end

  filter_with StatusFilter, :id_filter, :account_id_filter, :phone_number_id_filter, :to_filter, :from_filter, :date_filter
end
