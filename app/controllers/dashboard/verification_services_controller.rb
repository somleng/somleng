module Dashboard
  class VerificationServicesController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:account))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = record
    end

    private

    def scope
      parent_scope.verification_services
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
