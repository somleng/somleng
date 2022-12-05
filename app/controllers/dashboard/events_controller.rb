module Dashboard
  class EventsController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:phone_call, :message))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = scope.find(params[:id])
    end

    private

    def scope
      current_carrier.events
    end
  end
end
