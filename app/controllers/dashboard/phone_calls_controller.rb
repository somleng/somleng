module Dashboard
  class PhoneCallsController < DashboardController
    def index
      @resources = apply_filters(phone_calls_scope.includes(:account))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = record
    end

    private

    def phone_calls_scope
      current_organization.phone_calls
    end

    def record
      @record ||= phone_calls_scope.find(params[:id])
    end
  end
end
