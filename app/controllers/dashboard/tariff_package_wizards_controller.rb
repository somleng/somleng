module Dashboard
  class TariffPackageWizardsController < DashboardController
    def new
      @resource = TariffPackageWizardForm.new(carrier: current_carrier)
    end

    def create
      @resource = TariffPackageWizardForm.new(carrier: current_carrier, **permitted_params)
      CreateTariffPackageWizardForm.call(@resource)
      respond_with(:dashboard, @resource, location: dashboard_tariff_packages_path)
    end

    private

    def permitted_params
      params.require(:tariff_package).permit(
        :name,
        :description,
        tariffs: [ :category, :enabled, :rate ]
      )
    end
  end
end
