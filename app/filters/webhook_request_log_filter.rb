class WebhookRequestLogFilter < ResourceFilter
  class FailedFilter < ApplicationFilter
    filter_params do
      optional(:failed).value(:bool)
    end

    def apply
      return super if filter_params.blank?

      super.where(failed: filter_params.fetch(:failed))
    end
  end

  filter_with FailedFilter, DateFilter
end
