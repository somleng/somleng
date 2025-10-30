module Dashboard
  class TariffBundlesController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:tariff_packages))
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = TariffBundleForm.new(carrier: current_carrier)
    end

    def create
      @resource = TariffBundleForm.new(carrier: current_carrier, **permitted_params)
      @resource.save
      respond_with(:dashboard, @resource, location: dashboard_tariff_bundles_path(filter_params))
    end

    def show
      @resource = record
    end

    def edit
      @resource = TariffBundleForm.initialize_with(record)
    end

    def update
      @resource = TariffBundleForm.initialize_with(record)
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
      params.require(:tariff_bundle).permit(
        :name, :description,
        line_items: [ :id, :tariff_package_id, :category ]
      )
    end

    def scope
      current_carrier.tariff_bundles
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
