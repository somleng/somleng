module Dashboard
  class DestinationGroupsController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:prefixes))
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = DestinationGroupForm.new(carrier: current_carrier)
    end

    def create
      @resource = DestinationGroupForm.new(carrier: current_carrier, **permitted_params)
      @resource.save
      respond_with(:dashboard, @resource, location: dashboard_destination_groups_path)
    end

    def show
      @resource = record
    end

    def edit
      @resource = DestinationGroupForm.initialize_with(record)
    end

    def update
      @resource = DestinationGroupForm.initialize_with(record)
      @resource.attributes = permitted_params.except(:catch_all)
      @resource.save
      respond_with(:dashboard, @resource)
    end

    def destroy
      @resource = record
      @resource.destroy
      respond_with(:dashboard, @resource)
    end

    private

    def record
      @record ||= scope.find(params[:id])
    end

    def permitted_params
      params.require(:destination_group).permit(:name, :catch_all, :prefixes)
    end

    def scope
      current_carrier.destination_groups
    end
  end
end
