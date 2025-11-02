module Dashboard
  class DestinationTariffsController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:destination_group, :tariff_schedule, tariff: [ :call_tariff, :message_tariff ]))
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = DestinationTariffForm.new(tariff_schedule: TariffSchedule.new(carrier: current_carrier))
    end

    private

    def scope
      current_carrier.destination_tariffs
    end
  end
end
