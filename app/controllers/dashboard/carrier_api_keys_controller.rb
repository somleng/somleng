module Dashboard
  class CarrierAPIKeysController < DashboardController
    def index
      @resources = apply_filters(scope)
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = record
    end

    def create
      @resource = CarrierAPIKey.create!(oauth_application: current_carrier.oauth_application)
      respond_with(@resource, location: -> { dashboard_carrier_settings_api_keys_path(filter_params) })
    end

    def destroy
      record.revoke
      respond_with(record, location: -> { dashboard_carrier_settings_api_key_path(record) })
    end

    private

    def scope
      current_carrier.api_keys
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
