module Dashboard
  class TariffPlansController < DashboardController
    helper_method :filter_params

    def index
      @resources = apply_filters(scope)
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = TariffPlanForm.new(
        carrier: current_carrier,
        tariff_package_id: @current_carrier.tariff_packages.find(request.query_parameters.dig(:filter, :tariff_package_id)).id,
        **request.query_parameters.fetch(:filter, {}).slice(:tariff_schedule_id)
      )
    end

    def create
      @resource = TariffPlanForm.new(carrier: current_carrier, **permitted_params)
      @resource.save
      respond_with(:dashboard, @resource, location: dashboard_tariff_plans_path(filter_params))
    end

    def show
      @resource = record
    end

    def destroy
      @resource = record
      @resource.destroy
      respond_with(:dashboard, @resource)
    end

    private

    def permitted_params
      params.require(:tariff_plan).permit(:tariff_package_id, :tariff_schedule_id)
    end

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
