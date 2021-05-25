module Dashboard
  class ExportsController < DashboardController
    def index
      @resources = paginate_resources(current_user.exports)
    end

    def create
      @resource = Export.new(permitted_params)
      @resource.user = current_user
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

    def permitted_params
      params.require(:export).permit(:resource_type, :name, filter_params: {})
    end
  end
end
