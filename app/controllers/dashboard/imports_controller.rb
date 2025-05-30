module Dashboard
  class ImportsController < DashboardController
    def index
      @resources = paginate_resources(current_user.imports)
    end

    def create
      @import = build_import
      if @import.save
        ExecuteWorkflowJob.perform_later(ImportCSV.to_s, @import)
        flash[:notice] = "Your import is being processed. You can view its status from the #{helpers.link_to('Imports', dashboard_imports_path)} page."
      else
        flash[:alert] = "Failed to create import: #{@import.errors.full_messages.to_sentence}"
      end

      redirect_back_or_to(dashboard_imports_path)
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
