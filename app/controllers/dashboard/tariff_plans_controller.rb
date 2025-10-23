module Dashboard
  class TariffPlansController < DashboardController
    helper_method :filter_params

    def index
      @resources = apply_filters(scope)
      @resources = paginate_resources(@resources)
    end

    private

    def scope
      current_carrier.tariff_plans
    end

    def record
      @record ||= scope.find(params[:id])
    end

    def filter_params
      request.query_parameters.slice(:filter)
    end
  end
end
