require_relative "boot"

require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Twilreapi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.active_support.escape_html_entities_in_json = false

    config.active_job.queue_adapter = :active_elastic_job

    config.twilreapi = config_for(:twilreapi)
  end
end
