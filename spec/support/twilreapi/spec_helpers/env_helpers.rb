module Twilreapi::SpecHelpers::EnvHelpers
  private

  def stub_secrets(secrets)
    allow(Rails.application.secrets).to receive(:[]).and_call_original
    allow(Rails.application.secrets).to receive(:fetch).and_call_original

    secrets.each do |key, value|
      allow(
        Rails.application.secrets
      ).to receive(:[]).with(key).and_return(value.present? && value.to_s)

      allow(
        Rails.application.secrets
      ).to receive(:fetch).with(key).and_return(value.present? && value.to_s)
    end
  end

  def stub_env(env)
    allow(ENV).to receive(:[]).and_call_original

    env.each do |key, value|
      allow(ENV).to receive(:[]).with(key.to_s.upcase).and_return(value)
    end
  end
end

RSpec.configure do |config|
  config.include(Twilreapi::SpecHelpers::EnvHelpers)
end
