module Dashboard
  class TariffPackagesController < DashboardController
    def index
      @resources = apply_filters(scope)
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = TariffPackageForm.new(carrier: current_carrier)
    end

    def create
      @resource = TariffPackageForm.new(carrier: current_carrier, **permitted_params)
      @resource.save
      respond_with(:dashboard, @resource)
    end

    def show
      @resource = record
    end

    def edit
      @resource = TariffPackageForm.initialize_with(record)
    end

    def update
      @resource = TariffPackageForm.initialize_with(record)
      @resource.attributes = permitted_params.except(:category)
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
      params.require(:tariff_package).permit(:name, :category, :description)
    end

    def scope
      current_carrier.tariff_packages
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
