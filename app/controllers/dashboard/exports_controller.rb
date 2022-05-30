module Dashboard
  class ExportsController < DashboardController
    def index
      @resources = paginate_resources(current_user.exports)
    end

    def create
      @resource = build_export
      @resource.save!
      ExecuteWorkflowJob.perform_later("ExportCSV", @resource)

      redirect_back(
        fallback_location: dashboard_exports_path,
        flash: {
          notice: "Your export is being processed. You can view its status from the #{helpers.link_to('Exports', dashboard_exports_path)} page."
        }
      )
    end

    private

    def build_export
      @resource = Export.new(permitted_params)
      @resource.user = current_user
      if current_user.carrier_user?
        @resource.scoped_to[:carrier_id] = current_carrier.id
      else
        @resource.scoped_to[:account_id] = current_account.id
      end
      @resource
    end

    def permitted_params
      params.require(:export).permit(:resource_type, :name, filter_params: {})
    end
  end
end
