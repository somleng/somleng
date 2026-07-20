TTSVoices.configure do |config|
  if Rails.env.development? || Rails.env.test?
    # Use stub_responses for Polly
    config.voices = ["Basic", "Polly"]
  else
    config.azure_options = {
      region: Rails.configuration.app_settings[:azure_speech_region],
      key: Rails.configuration.app_settings[:azure_speech_key],
    }
  end
end
