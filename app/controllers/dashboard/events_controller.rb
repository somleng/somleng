module Dashboard
  class EventsController < DashboardController
    def index
      @resources = apply_filters(events_scope)
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = events_scope.find(params[:id])
    end

    private

    def events_scope
      current_carrier.events
    end
  end
end
