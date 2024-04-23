module Dashboard
  class PhoneNumberPlansController < DashboardController
    def index
      @resources = paginate_resources(apply_filters(scope.includes(:account)))
    end

    def show
      @resource = record
    end

    private

    def scope
      parent_scope.phone_number_plans
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
