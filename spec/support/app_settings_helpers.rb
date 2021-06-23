module AppSettingsHelpers
  def stub_app_settings(app_settings)
    allow(Rails.configuration.app_settings).to receive(:[]).and_call_original
    allow(Rails.configuration.app_settings).to receive(:fetch).and_call_original

    app_settings.each do |key, value|
      allow(Rails.configuration.app_settings).to receive(:[]).with(key).and_return(value)
      allow(Rails.configuration.app_settings).to receive(:fetch).with(key).and_return(value)
    end
  end
end

RSpec.configure do |config|
  config.include AppSettingsHelpers
end
