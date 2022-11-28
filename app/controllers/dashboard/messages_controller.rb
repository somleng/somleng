module Dashboard
  class MessagesController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:account))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = record
    end

    private

    def scope
      parent_scope.messages
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
