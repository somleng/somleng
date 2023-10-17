module Dashboard
  class AccountSettingsController < DashboardController
    def show
      @resource = current_account
    end

    def edit
      @resource = AccountSettingsForm.initialize_with(current_account)
    end

    def update
      default_tts_configuration = DefaultTTSConfigurationForm.new(
        default_tts_configuration: current_account.default_tts_configuration,
        **permitted_params[:default_tts_configuration]
      )
      @resource = AccountSettingsForm.new(permitted_params.merge(default_tts_configuration:))
      @resource.account = current_account
      @resource.save

      respond_with(@resource, location: dashboard_account_settings_path)
    end

    private

    def permitted_params
      params.require(:account_settings).permit(
        :name,
        default_tts_configuration: %i[
          provider
          language
        ]
      )
    end

    def policy_class
      AccountSettingsPolicy
    end

    def record
      @record ||= current_account
    end
  end
end
