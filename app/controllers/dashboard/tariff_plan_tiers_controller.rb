module Dashboard
  class TariffPlanTiersController < DashboardController
    def new
      @resource = TariffPlanTierForm.new(tariff_package: TariffPackage.new(carrier: current_carrier))
    end
  end
end
