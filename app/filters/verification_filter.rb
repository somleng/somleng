class VerificationFilter < ResourceFilter
  class VerificationServiceIDFilter < ApplicationFilter
    filter_params do
      optional(:verification_service_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(verification_service_id: filter_params.fetch(:verification_service_id))
    end
  end

  class StatusFilter < ApplicationFilter
    filter_params do
      optional(:status).value(:string, included_in?: VerificationDecorator.statuses)
    end

    def apply
      return super if filter_params.blank?

      status = filter_params.fetch(:status)
      if status == "pending"
        super.pending
      elsif status == "expired"
        super.expired
      else
        super.where(status:)
      end
    end
  end

  filter_with VerificationServiceIDFilter, StatusFilter, :account_id_filter, :date_filter
end
