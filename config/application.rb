require_relative "boot"

require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Somleng
  class Application < Rails::Application
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    config.load_defaults 7.0

    config.active_support.escape_html_entities_in_json = false

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.eager_load_paths << Rails.root.join("lib")
    config.app_settings = config_for(:app_settings)
    config.active_job.default_queue_name = config.app_settings.fetch(:aws_sqs_default_queue_name)
    Rails.application.routes.default_url_options[:host] = config.app_settings.fetch(:dashboard_url_host)

    encryption_config = config.app_settings.fetch(:active_record_encryption)
    config.active_record.encryption.primary_key = encryption_config.fetch(:primary_key)
    config.active_record.encryption.deterministic_key = encryption_config.fetch(:deterministic_key)
    config.active_record.encryption.key_derivation_salt = encryption_config.fetch(:key_derivation_salt)
  end
end

require "call_service"
