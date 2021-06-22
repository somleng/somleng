class Users::RegistrationsController < Devise::RegistrationsController
  include UserAuthorization
  layout "dashboard"

  before_action :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def after_update_path_for(_resource)
    sign_in_after_change_password? ? edit_user_registration_path : new_session_path(resource_name)
  end
end
