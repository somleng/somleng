module Dashboard
  class TTSEventsController < DashboardController
    def index
      @resources = apply_filters(tts_events_scope.includes(:account))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = record
    end

    private

    def tts_events_scope
      current_carrier.tts_events
    end

    def record
      @record ||= tts_events_scope.find(params[:id])
    end
  end
end
