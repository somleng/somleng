# Be sure to restart your server when you modify this file.

Rails.application.config.session_store(
  :cookie_store,
  key: "_somleng_session",
  domain: Addressable::URI.parse(Rails.configuration.app_settings.fetch(:dashboard_url_host)).domain
)
