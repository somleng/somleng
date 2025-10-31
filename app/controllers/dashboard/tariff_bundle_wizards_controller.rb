module Dashboard
  class TariffBundleWizardsController < DashboardController
    def new
      @resource = TariffBundleWizardForm.new(carrier: current_carrier)
    end

    def create
      @resource = TariffBundleWizardForm.new(carrier: current_carrier, **permitted_params)
      @resource.save
      respond_with(:dashboard, @resource, location: dashboard_tariff_bundles_path)
    end

    private

    def permitted_params
      params.require(:tariff_bundle).permit(
        :name,
        :description,
        tariffs: [ :category, :enabled, :rate ]
      )
    end
  end
end
