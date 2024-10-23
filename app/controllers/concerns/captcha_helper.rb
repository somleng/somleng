module CaptchaHelper
  private

  def verify_captcha(**options)
    failure_block = options.delete(:on_failure) || -> { render(:new) }
    return yield if verify_recaptcha(minimum_score: Rails.configuration.app_settings.fetch(:recaptcha_minimum_score, 0.7), **options)
    return yield if verify_recaptcha(secret_key: Rails.configuration.app_settings.fetch(:recaptcha_fallback_secret_key))

    @show_checkbox_captcha = true
    failure_block.call
  end
end
