class Users::RegistrationsController < Devise::RegistrationsController
  include UserAuthorization
  include CaptchaHelper

  skip_before_action :select_account_membership!, only: %i[new create]
  skip_before_action :authorize_user!, only: %i[new create]
  skip_before_action :authorize_carrier!, only: %i[new create]
  skip_after_action :verify_authorized, only: %i[new create]
  before_action :configure_account_update_parameters, only: :update
  before_action :configure_sign_up_parameters, only: :create

  layout :resolve_layout

  self.raise_on_open_redirects = false
  self.action_on_open_redirect = :log

  def create
    verify_captcha(action: :sign_up, on_failure: -> { on_captcha_failure }) do
      super do |form|
        self.resource = form.user if form.persisted?
      end
    end
  end

  protected

  def configure_account_update_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def configure_sign_up_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: %i[
        name
        work_email
        company
        subdomain
        country
        website
      ]
    )
  end

  def after_update_path_for(_resource)
    sign_in_after_change_password? ? edit_user_registration_path : new_session_path(resource_name)
  end

  def after_inactive_sign_up_path_for(resource)
    new_session_url(resource_name, host: resource.carrier.subdomain_host, after_sign_up: true)
  end

  def build_resource(hash = {})
    self.resource = CarrierForm.new(hash)
  end

  private

  def resolve_layout
    user_signed_in? ? "dashboard" : "devise"
  end

  def on_captcha_failure
    build_resource(sign_up_params)
    render(:new)
  end
end
