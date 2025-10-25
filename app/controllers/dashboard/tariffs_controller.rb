module Dashboard
  class TariffsController < DashboardController
    def index
      @resources = apply_filters(scope)
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = TariffForm.new(carrier: current_carrier)
    end

    def create
      @resource = TariffForm.new(carrier: current_carrier, **permitted_params)
      @resource.save
      respond_with(:dashboard, @resource, location: dashboard_tariffs_path)
    end

    def show
      @resource = record
    end

    def edit
      @resource = TariffForm.initialize_with(record)
    end

    def update
      @resource = TariffForm.initialize_with(record)
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

    def scope
      current_carrier.tariffs
    end

    def record
      @record ||= scope.find(params[:id])
    end

    def permitted_params
      params.require(:tariff).permit(
        :category,
        :name,
        :description,
        :message_rate,
        :call_per_minute_rate,
        :call_connection_fee
      )
    end
  end
end
