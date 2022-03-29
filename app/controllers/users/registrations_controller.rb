class Users::RegistrationsController < Devise::RegistrationsController
  include UserAuthorization

  skip_before_action :authorize_user!, only: %i[new create]
  skip_after_action :verify_authorized, only: %i[new create]
  before_action :configure_account_update_parameters, only: :update
  before_action :configure_sign_up_parameters, only: :create

  layout :resolve_layout

  def create
    super do |form|
      self.resource = form.user if form.user.persisted?
    end
  end

  protected

  def configure_account_update_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def configure_sign_up_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: %i[
        name
        work_email
        company
        country
        website
      ]
    )
  end

  def after_update_path_for(_resource)
    sign_in_after_change_password? ? edit_user_registration_path : new_session_path(resource_name)
  end

  def after_inactive_sign_up_path_for(_resource)
    new_session_path(resource_name)
  end

  def build_resource(hash = {})
    self.resource = CarrierForm.new(hash)
  end

  private

  def resolve_layout
    user_signed_in? ? "dashboard" : "devise"
  end
end
