module Dashboard
  class DestinationTariffsController < DashboardController
    def new
      @resource = DestinationTariffForm.new(schedule: TariffSchedule.new(carrier: current_carrier))
    end
  end
end
