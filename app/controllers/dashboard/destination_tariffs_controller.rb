module Dashboard
  class DestinationTariffsController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:destination_group, :tariff_schedule, tariff: [ :call_tariff, :message_tariff ]))
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = DestinationTariffForm.new(carrier: current_carrier, **request.query_parameters.slice(:tariff_schedule_id, :tariff_id, :destination_group_id))
    end

    def create
      @resource = DestinationTariffForm.new(carrier: current_carrier, **permitted_params)
      @resource.save
      respond_with(:dashboard, @resource)
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
  end
end
