module Dashboard
  class TariffPlanTiersController < DashboardController
    def new
      @resource = TariffPlanTierForm.new(tariff_plan: TariffPlan.new(carrier: current_carrier))
    end
  end
end
