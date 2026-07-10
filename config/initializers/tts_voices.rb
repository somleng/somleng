TTSVoices.configure do |config|
  if Rails.env.development? || Rails.env.test?
    # Use stub_responses for Polly
    config.voices = ["Basic", "Polly"]
  else
    config.azure_options = {
      region: AppSettings.fetch(:azure_speech_region),
      key: AppSettings.fetch(:azure_speech_key),
    }
  end
end
