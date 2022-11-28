class PhoneCallFilter < ResourceFilter
  class StatusFilter < ApplicationFilter
    filter_params do
      optional(:status).value(
        :string,
        included_in?: PhoneCallDecorator.statuses
      )
    end

    def apply
      return super if filter_params.blank?

      super.where(
        status: PhoneCallDecorator::TWILIO_CALL_STATUS_MAPPINGS.rassoc(
          filter_params.fetch(:status)
        )
      )
    end
  end

  filter_with IDFilter, StatusFilter, AccountIDFilter, ToFilter, FromFilter, DateFilter
end
