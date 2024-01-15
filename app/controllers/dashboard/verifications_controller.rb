module Dashboard
  class VerificationsController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:verification_service, :account))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = record
    end

    private

    def scope
      parent_scope.verifications
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
