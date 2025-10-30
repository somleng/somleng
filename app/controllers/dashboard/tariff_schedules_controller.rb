module Dashboard
  class TariffSchedulesController < DashboardController
    def index
      @resources = apply_filters(scope)
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = TariffScheduleForm.new(carrier: current_carrier, **request.query_parameters.fetch(:filter, {}).slice(:category))
    end

    def create
      @resource = TariffScheduleForm.new(carrier: current_carrier, **permitted_params)
      @resource.save
      respond_with(:dashboard, @resource, location: dashboard_tariff_schedules_path(filter_params))
    end

    def show
      @resource = record
    end

    def edit
      @resource = TariffScheduleForm.initialize_with(record)
    end

    def update
      @resource = TariffScheduleForm.initialize_with(record)
      @resource.attributes = permitted_params.except(:category)
      @resource.save
      respond_with(:dashboard, @resource)
    end

    def destroy
      @resource = record
      @resource.destroy
      respond_with(:dashboard, @resource)
    end

    private

    def permitted_params
      params.require(:tariff_schedule).permit(:name, :category, :description)
    end

    def scope
      current_carrier.tariff_schedules
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
