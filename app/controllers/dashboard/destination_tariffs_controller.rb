module Dashboard
  class DestinationTariffsController < DashboardController
    helper_method :filter_params

    def index
      @resources = apply_filters(scope.includes(:destination_group, :tariff_schedule, tariff: [ :call_tariff, :message_tariff ]))
      @resources = paginate_resources(@resources)
    end

    def new
      @tariff_schedule = current_carrier.tariff_schedules.find(request.query_parameters.dig(:filter, :tariff_schedule_id))
      @resource = DestinationTariffForm.new(
        carrier: current_carrier,
        tariff_schedule_id: @tariff_schedule.id,
        **request.query_parameters.fetch(:filter, {}).slice(:destination_group_id, :tariff_id)
      )
    end

    def create
      @resource = DestinationTariffForm.new(carrier: current_carrier, **permitted_params)
      @resource.save
      respond_with(:dashboard, @resource, location: dashboard_destination_tariffs_path(filter_params))
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
      params.require(:destination_tariff).permit(:tariff_schedule_id, :tariff_id, :destination_group_id)
    end

    def scope
      current_carrier.destination_tariffs
    end

    def record
      @record ||= scope.find(params[:id])
    end

    def filter_params
      request.query_parameters.slice(:filter)
    end
  end
end
