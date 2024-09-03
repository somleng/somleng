SomlengRegions.configure do |config|
  config.region_data = Rails.configuration.app_settings.fetch(:region_data)
  config.stub_regions = Rails.configuration.app_settings.fetch(:stub_regions)
end
