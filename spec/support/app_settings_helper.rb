module AppSettingsHelper
  def stub_app_settings(settings)
    allow(Rails.configuration.app_settings).to receive(:fetch).and_call_original
    allow(Rails.configuration.app_settings).to receive(:[]).and_call_original

    settings.each do |key, value|
      allow(Rails.configuration.app_settings).to receive(:fetch).with(key.to_sym).and_return(value)
      allow(Rails.configuration.app_settings).to receive(:[]).with(key.to_sym).and_return(value)
    end
  end
end

RSpec.configure do |config|
  config.include(AppSettingsHelper)
end
