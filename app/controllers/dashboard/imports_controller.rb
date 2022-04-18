module Dashboard
  class ImportsController < DashboardController
    def create
      @resource = build_import
      @resource.save!
      # ExecuteWorkflowJob.perform_later("ExportCSV", @resource)

      redirect_back(
        fallback_location: dashboard_imports_path,
        flash: {
          notice: "Your import is being processed. You can view its status from the #{helpers.link_to('Imports', dashboard_imports_path)} page."
        }
      )
    end

    private

    def build_import
      @resource = Import.new(permitted_params)
      @resource.user = current_user
      @resource.carrier = current_carrier
      @resource
    end

    def permitted_params
      params.require(:import).permit(:resource_type, :file)
    end
  end
end
