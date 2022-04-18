module Dashboard
  class ImportsController < DashboardController
    def index
      @resources = paginate_resources(current_user.imports)
    end

    def create
      @resource = build_import
      if @resource.save
        flash[:notice] = "Your import is being processed. You can view its status from the #{helpers.link_to('Imports', dashboard_imports_path)} page."
      else
        flash[:alert] = "Your import failed with the following error: #{@resource.errors.full_messages.to_sentence}"
      end

      redirect_back(
        fallback_location: dashboard_imports_path
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
