module Dashboard
  class NotificationPreferencesController < DashboardController
    def edit
      @resource = NotificationPreferencesForm.initialize_with(current_user)
    end

    def update
      @resource = NotificationPreferencesForm.new(permitted_params)
      @resource.user = current_user
      @resource.save
      respond_with(:dashboard, @resource, location: edit_dashboard_notification_preferences_path)
    end

    private

    def permitted_params
      params.require(:notification_preferences).permit(subscribed_notification_topics: [])
    end

    def policy_class
      NotificationPreferencesPolicy
    end

    def record
      @record ||= current_user
    end
  end
end
