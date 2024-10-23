RSpec.configure do |config|
  config.around(captcha: true) do |example|
    skip_verify_env = Recaptcha.configuration.skip_verify_env.dup
    Recaptcha.configuration.skip_verify_env.delete("test")
    example.run
    Recaptcha.configuration.skip_verify_env = skip_verify_env
  end
end
