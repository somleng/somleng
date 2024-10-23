class Users::SessionsController < Devise::SessionsController
  include CaptchaHelper

  def create
    verify_captcha(action: :sign_in, on_failure: -> { on_captcha_failure }) { super }
  end

  private

  def on_captcha_failure
    self.resource = resource_class.new(sign_in_params)
    render(:new)
  end
end
