module Dashboard
  class WebhookRequestLogsController < DashboardController
    def index
      @resources = apply_filters(request_logs_scope.includes(:event))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = request_logs_scope.find(params[:id])
    end

    private

    def request_logs_scope
      current_carrier.webhook_request_logs
    end
  end
end
