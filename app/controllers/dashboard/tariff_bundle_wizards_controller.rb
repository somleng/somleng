module Dashboard
  class TariffBundleWizardsController < DashboardController
    def new
      @resource = TariffBundleWizardForm.new(carrier: current_carrier)
    end
  end
end
