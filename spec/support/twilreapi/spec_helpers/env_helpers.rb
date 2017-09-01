module Twilreapi::SpecHelpers::EnvHelpers
  private

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
