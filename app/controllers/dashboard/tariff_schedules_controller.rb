module Dashboard
  class TariffSchedulesController < DashboardController
    def index
      @resources = apply_filters(scope.includes(destination_tariffs: [ :destination_group, :tariff ]))
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = TariffScheduleForm.new(carrier: current_carrier, **request.query_parameters.fetch(:filter, {}).slice(:category))
    end

    def create
      permitted_params = params.require(:tariff_schedule).permit(
        :name, :description, :category, destination_tariffs: [ :destination_group_id, :rate ]
      )
      @resource = TariffScheduleForm.new(carrier: current_carrier, **permitted_params)
      UpdateTariffScheduleForm.call(@resource)
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
      @resource.attributes = params.require(:tariff_schedule).permit(
        :name, :description, destination_tariffs: [
          :id, :destination_group_id, :rate, :_destroy
        ]
      )
      UpdateTariffScheduleForm.call(@resource)
      respond_with(:dashboard, @resource)
    end

    def destroy
      @resource = record
      DestroyTariffSchedule.call(@resource)
      respond_with(:dashboard, @resource)
    end

    private

    def scope
      current_carrier.tariff_schedules
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
