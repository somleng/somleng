module Dashboard
  class ErrorLogsController < DashboardController
    def index
      @resources = paginate_resources(apply_filters(scope.includes(:account)))
    end

    private

    def scope
      parent_scope.error_logs
    end
  end
end
