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

  class EventFilter < ApplicationFilter
    filter_params do
      optional(:event_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(event_id: filter_params.fetch(:event_id))
    end
  end

  filter_with FailedFilter, EventFilter, :date_filter
end
