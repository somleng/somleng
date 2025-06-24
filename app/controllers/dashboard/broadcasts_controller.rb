module Dashboard
  class BroadcastsController < DashboardController
    Badge = Data.define(:color, :icon)

    helper_method :broadcast_badge

    def index
      @broadcasts = FakeResource::Broadcast.all
    end

    def show
      @broadcast = FakeResource::Broadcast.find(params[:id])
    end

    def update
      @broadcast = FakeResource::Broadcast.find(params[:id])
      respond_with(:dashboard, @broadcast)
    end

    private

    def broadcast_badge(type)
      case type
      when "sms"
        Badge.new(color: "bg-success", icon: "message")
      when "pending"
        Badge.new(color: "bg-secondary", icon: "clock")
      when "in_progress"
        Badge.new(color: "bg-primary", icon: "hourglass-start")
      when "completed"
        Badge.new(color: "bg-success", icon: "circle-check")
      when "canceled"
        Badge.new(color: "bg-danger", icon: "triangle-exclamation")
      end
    end
  end
end
