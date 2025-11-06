module Dashboard
  class DestinationTariffsController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:destination_group, :tariff_schedule, tariff: [ :call_tariff, :message_tariff ]))
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = DestinationTariffForm.new(tariff_schedule: TariffSchedule.new(carrier: current_carrier))
    end

    def show
      @resource = record
    end

    def edit
      @resource = DestinationTariffForm.initialize_with(record)
    end

    def update
      @resource = DestinationTariffForm.initialize_with(record)
      @resource.attributes = permitted_params
      @resource.save
      respond_with(:dashboard, @tariff_schedule, @resource)
    end

    def destroy
      @resource = record
      @resource.destroy
      respond_with(:dashboard, @resource, location: dashboard_tariff_schedule_destination_tariffs_path(tariff_schedule))
    end

    private

    def permitted_params
      params.require(:destination_tariff).permit(:destination_group_id, :rate)
    end

    def tariff_schedule
      @tariff_schedule ||= current_carrier.tariff_schedules.find(params[:tariff_schedule_id])
    end

    def scope
      tariff_schedule.destination_tariffs
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
