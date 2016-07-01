module Twilreapi::SpecHelpers::EnvHelpers
  private

  def stub_env(env)
    allow(Rails.application.secrets).to receive(:[]).and_call_original

    env.each do |key, value|
      allow(Rails.application.secrets).to receive(:[]).with(key.to_s.downcase.to_sym).and_return(value)
      allow(Rails.application.secrets).to receive(:[]).with(key.to_s.downcase).and_return(value)
    end
  end
end
