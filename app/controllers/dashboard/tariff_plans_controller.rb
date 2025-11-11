module Dashboard
  class TariffPlansController < DashboardController
    def index
      @resources = apply_filters(scope)
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = TariffPlanForm.new(
        carrier: current_carrier,
        **request.query_parameters.fetch(:filter, {}).slice(:category)
      )
    end

    def create
      permitted_params = params.require(:tariff_plan).permit(
        :name, :category, :description, tiers: [ :tariff_schedule_id, :weight ]
      )
      @resource = TariffPlanForm.new(carrier: current_carrier, **permitted_params)
      @resource.save
      respond_with(:dashboard, @resource, location: dashboard_tariff_plans_path(filter_params))
    end

    def show
      @resource = record
      @tariff_calculation = TariffCalculation.new(tariff_plan: record, **request.query_parameters.fetch(:tariff_calculation, {}).slice(:destination).symbolize_keys)
      @tariff_calculation.calculate
    end

    def edit
      @resource = TariffPlanForm.initialize_with(record)
    end

    def update
      @resource = TariffPlanForm.initialize_with(record)
      permitted_params = params.require(:tariff_plan).permit(
        :name, :description, tiers: [ :id, :tariff_schedule_id, :weight, :_destroy ]
      )
      @resource.attributes = permitted_params
      @resource.save
      respond_with(:dashboard, @resource)
    end

    def destroy
      @resource = record
      @resource.destroy
      respond_with(:dashboard, @resource)
    end

    private

    def scope
      current_carrier.tariff_plans
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
