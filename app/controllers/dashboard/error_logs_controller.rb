module Dashboard
  class ErrorLogsController < DashboardController
    def index
      @resources = apply_filters(error_logs_scope.includes(:carrier, :account))
      @resources = paginate_resources(@resources)
    end

    private

    def error_logs_scope
      parent_scope.error_logs
    end
  end
end
