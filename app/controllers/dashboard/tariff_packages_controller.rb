module Dashboard
  class TariffPackagesController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:tariff_plans))
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = TariffPackageForm.new(carrier: current_carrier)
    end

    def create
      @resource = TariffPackageForm.new(carrier: current_carrier, **permitted_params)
      @resource.save
      respond_with(:dashboard, @resource, location: dashboard_tariff_packages_path(filter_params))
    end

    def show
      @resource = record
    end

    def edit
      @resource = TariffPackageForm.initialize_with(record)
    end

    def update
      @resource = TariffPackageForm.initialize_with(record)
      @resource.attributes = permitted_params
      @resource.save
      respond_with(:dashboard, @resource)
    end

    def destroy
      @resource = record
      @resource.destroy
      respond_with(:dashboard, @resource)
    end

    private

    def permitted_params
      params.require(:tariff_package).permit(
        :name, :description,
        line_items: [ :id, :tariff_plan_id, :category ]
      )
    end

    def scope
      current_carrier.tariff_packages
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
